#include <thread>

#include "SoundManager.h"
#include "SimpleAudioEngine.h"

USING_NS_CC;
using namespace CocosDenshion;

#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
const std::string strSounds = "sounds_ios.plist";
const std::string strMusic = "music_ios.plist";
#elif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
const std::string strSounds = "sounds_android.plist";
const std::string strMusic = "music_android.plist";
#else
const std::string strSounds = "sounds.plist";
const std::string strMusic = "music.plist";
#endif


const std::string strKeyMusicVolume = "MusicVolume";
const std::string strKeySoundVolume = "SoundVolume";

const std::string strIsMusicOn = "strIsMusicOn";
const std::string strIsSoundOn = "strIsSoundOn";

void threadWorker()
{
	////sounds
	auto soundMap = SoundManager::getInstance()->getSoundMap();
	soundMap.clear();
	soundMap = FileUtils::getInstance()->getValueMapFromFile(strSounds);

	if(soundMap.empty())
		return;

	for(auto mapItr = soundMap.begin(); mapItr!=soundMap.end(); mapItr++)
	{
		std::string soundPath = mapItr->second.asString();
		SimpleAudioEngine::getInstance()->preloadEffect(soundPath.c_str());
	}

	////music

	auto musicMap = SoundManager::getInstance()->getMusicMap();
	musicMap.clear();
	musicMap = FileUtils::getInstance()->getValueMapFromFile(strMusic);
	if(musicMap.empty())
		return;

	for(auto mapItr = musicMap.begin(); mapItr!=musicMap.end(); mapItr++)
	{
		std::string soundPath = mapItr->second.asString();
		SimpleAudioEngine::getInstance()->preloadBackgroundMusic(soundPath.c_str());
	}
}


void threadPreLoad()
{
	std::thread th(threadWorker);
	th.detach();
}

SoundManager::SoundManager()
	: m_musicName("")
	, m_bMusicOn(false)
	, m_bSoundOn(false)
	, m_musicVolume(1.0f)
	, m_soundVolume(1.0f)
{

}

SoundManager::~SoundManager()
{

}

static SoundManager* s_pSoundManager = nullptr;
SoundManager* SoundManager::getInstance()
{
	if (s_pSoundManager == nullptr)
	{
		s_pSoundManager = new SoundManager();
		s_pSoundManager->init();
	}
	return s_pSoundManager;
}

bool SoundManager::init()
{
	threadPreLoad();

	setMusicState(UserDefault::getInstance()->getBoolForKey(strIsMusicOn.c_str(), true));
	setSoundState(UserDefault::getInstance()->getBoolForKey(strIsSoundOn.c_str(), true));

	setMusicVolume(UserDefault::getInstance()->getFloatForKey(strKeyMusicVolume.c_str(), 1.0f));
	setSoundVolume(UserDefault::getInstance()->getFloatForKey(strKeySoundVolume.c_str(), 1.0f));
	 
	return true;
}

bool SoundManager::getMusicState() const
{
	return m_bMusicOn;
}

bool SoundManager::getSoundState() const
{
	return m_bSoundOn;
}

void SoundManager::setMusicState(bool bOn)
{
	m_bMusicOn = bOn;
	UserDefault::getInstance()->setBoolForKey(strIsMusicOn.c_str(), bOn);
}

void SoundManager::setSoundState(bool bOn)
{
	m_bSoundOn = bOn;
	UserDefault::getInstance()->setBoolForKey(strIsSoundOn.c_str(), bOn);
}

void SoundManager::purge()
{
	delete s_pSoundManager;
	s_pSoundManager = nullptr;
}


void SoundManager::play(const std::string& key, const AUDIO_TYPE& soundType)
{
	if(key.empty())
		return;

	if(soundType == AUDIO_TYPE::EFFECT_TYPE && m_bMusicOn)
	{
		SimpleAudioEngine::getInstance()->playEffect(m_SoundMap[key].asString().c_str());
	}
	else if(soundType == AUDIO_TYPE::MUSIC_TYPE && m_bSoundOn)
	{
		if (m_musicName == m_MusicMap[key].asString())
		{
			return;
		}
		m_musicName = m_MusicMap[key].asString();
		stopMusic();
		SimpleAudioEngine::getInstance()->playBackgroundMusic(m_musicName.c_str(), true);
	}
}

void SoundManager::saveSettings()
{
	UserDefault::getInstance()->setFloatForKey(strKeyMusicVolume.c_str(), m_musicVolume);
	UserDefault::getInstance()->setFloatForKey(strKeySoundVolume.c_str(), m_soundVolume);
}

void SoundManager::stopMusic()
{
	SimpleAudioEngine::getInstance()->stopBackgroundMusic();
}

void SoundManager::stopAll()
{
	stopMusic();
	SimpleAudioEngine::getInstance()->stopAllEffects();
}

float SoundManager::getMusicVolume() const
{
	return m_musicVolume;
}

float SoundManager::getSoundVolume() const
{
	return m_soundVolume;
}

void SoundManager::setMusicVolume(float volume)
{
	m_musicVolume = volume;
	SimpleAudioEngine::getInstance()->setBackgroundMusicVolume(m_musicVolume);
}

void SoundManager::setSoundVolume(float volume)
{
	m_soundVolume = volume;
	SimpleAudioEngine::getInstance()->setEffectsVolume(m_soundVolume);
}

void SoundManager::pause()
{
	SimpleAudioEngine::getInstance()->pauseAllEffects();
	SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
}

void SoundManager::resume()
{
	SimpleAudioEngine::getInstance()->resumeAllEffects();
	SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}