#ifndef _SoundManager_H_
#define _SoundManager_H_

#include "cocos2d.h"


enum class AUDIO_TYPE
{
	EFFECT_TYPE = 0,
	MUSIC_TYPE,
};


class SoundManager
{
public:
	static SoundManager* getInstance();
	static void purge();

	 ~SoundManager();

	 void play(const std::string& key, const AUDIO_TYPE& soundType);
	 void stopMusic();
	 void stopAll();

	 float getMusicVolume() const;
	 float getSoundVolume() const;
	 void  setMusicVolume(float volume);
	 void  setSoundVolume(float volume);

	 bool getMusicState() const;
	 bool getSoundState() const;
	 void setMusicState(bool bOn);
	 void setSoundState(bool bOn);

	 void saveSettings();
	 void pause();
	 void resume();

	 cocos2d::ValueMap& getSoundMap(){ return m_SoundMap; }
	 cocos2d::ValueMap& getMusicMap(){ return m_MusicMap; }

private:
	SoundManager();
	bool init();

private:

	cocos2d::ValueMap            m_SoundMap;
	cocos2d::ValueMap            m_MusicMap;

	std::string			m_musicName;
	float               m_musicVolume;
	float               m_soundVolume;

	bool  m_bMusicOn;
	bool  m_bSoundOn;

};

#endif