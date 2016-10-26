﻿#include "CCDecryptImage.h"

#include <sstream>
#include "CCAES.h"
#include "CCCRC32.h"
#include "ccMacros.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include <WinSock.h>
#pragma comment(lib, "ws2_32.lib")
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <netinet/in.h>
#endif

namespace cocos2d
{
	/* CRC长度 */
	static const uint32_t CRC_SIZE = 4;

	/* 文件头部 */
	static const unsigned char HEAD_DATA[] = { 0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a };

	/* IEND CRC */
	static const unsigned char IEND_DATA[] = { 0xae, 0x42, 0x60, 0x82 };

	/* 默认密钥 */
	static const aes_key DEAULT_KEY = { 0x31, 0x32, 0x33, 0x34, 0x35, 0x36 };

#pragma pack(push, 1)

	struct Block
	{
		char name[4];
		uint32_t pos;
		uint32_t size;
	};

	struct IHDRBlock
	{
		Block block;
		char data[13 + CRC_SIZE];
	};

#pragma pack(pop)

	std::array<std::string, 2> splitext(const std::string &file_path)
	{
		std::string::size_type pos = file_path.rfind('.');
		std::array<std::string, 2> text;
		if (std::string::npos != pos)
		{
			text[1] = file_path.substr(pos);
			text[0] = file_path.substr(0, pos);
		}
		else
		{
			text[0] = file_path;
		}
		return text;
	}

	template <int _Value, typename _Stream>
	std::array<char, _Value> ReadSome(_Stream &stream)
	{
		std::array<char, _Value> buffer;
		for (unsigned int i = 0; i < _Value; ++i) buffer[i] = stream.get();
		return buffer;
	}

	void DecryptBlock(std::stringstream &ss, const aes_key &key)
	{
		const uint32_t contents_size = uint32_t(ss.tellp() - ss.tellg());
		assert(contents_size);

		uint32_t real_size = contents_size;
		if (real_size % AES_BLOCK_SIZE) real_size += AES_BLOCK_SIZE - contents_size % AES_BLOCK_SIZE;

		std::vector<uint8_t> buffer;
		buffer.resize(real_size);
		for (uint32_t i = 0; i < contents_size; ++i) buffer[i] = ss.get();
		AES::DecryptData(&buffer[0], real_size, key);
		ss.seekg(0); ss.seekp(0);
		for (uint32_t i = 0; i < real_size; ++i) ss.put(buffer[i]);
	}

	std::vector<unsigned char> DecryptImage(const std::string &filename, Data &data)
	{
		CCAssert(!data.isNull(), "data is null!");

		// 获取数据块信息位置
		const uint32_t block_start_pos = ntohl(*reinterpret_cast<uint32_t *>(data.getBytes() + data.getSize() - sizeof(uint32_t)));

		// 获取数据块大小
		uint32_t block_size;
		memcpy(&block_size, data.getBytes() + block_start_pos, sizeof(block_size));
		block_size = ntohl(block_size);

		// 获取数据块信息
		std::stringstream block_info;
		for (uint32_t i = block_start_pos + sizeof(uint32_t); i < data.getSize() - sizeof(uint32_t); ++i)
		{
			block_info.put(*(data.getBytes() + i));
		}

		// 解密数据块信息
		DecryptBlock(block_info, DEAULT_KEY);

		// 验证校验和
		block_info.seekg(block_size);
		uint32_t crc32 = ntohl(*reinterpret_cast<uint32_t*>(&ReadSome<sizeof(uint32_t)>(block_info)[0]));
		CCAssert(crc32 == CRC32(block_info.str().substr(0, block_size)), "crc32 error!");

		// 写入文件头信息
		std::vector<unsigned char> image_data;
		image_data.reserve(data.getSize());
		for (auto ch : HEAD_DATA) image_data.push_back(ch);

		// 写入数据块信息
		block_info.seekg(0);
		while (true)
		{
			CCAssert(block_info.tellg() < block_size, "file format error!");

			// 获取数据块信息
			Block block;
			memcpy(&block, &(ReadSome<sizeof(Block)>(block_info)[0]), sizeof(Block));

			// 写入数据块长度和名称
			char size_buffer[sizeof(block.size)];
			memcpy(size_buffer, &block.size, sizeof(size_buffer));
			for (auto ch : size_buffer) image_data.push_back(ch);
			for (auto ch : block.name) image_data.push_back(ch);

			block.pos = ntohl(block.pos);
			block.size = ntohl(block.size);

			// 根据数据块处理内容
			char block_name[sizeof(block.name) + 1] = { 0 };
			memcpy(block_name, block.name, sizeof(block.name));
			if (strcmp(block_name, "IHDR") == 0)
			{
				IHDRBlock ihdr;
				memcpy(&ihdr, &block, sizeof(Block));
				memcpy(((char *)&ihdr) + sizeof(Block), &ReadSome<sizeof(IHDRBlock) - sizeof(Block)>(block_info)[0], sizeof(IHDRBlock) - sizeof(Block));
				for (auto ch : ihdr.data) image_data.push_back(ch);
			}
			else if (strcmp(block_name, "IEND") == 0)
			{
				for (auto ch : IEND_DATA) image_data.push_back(ch);
				CCLOG("decrypt %s success!", filename.c_str());
				break;
			}
			else
			{
				for (uint32_t i = 0; i < block.size + CRC_SIZE; ++i)
				{
					image_data.push_back(*(data.getBytes() + block.pos + i));
				}
			}
		}

		return image_data;
	}
}