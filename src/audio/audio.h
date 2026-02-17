#ifndef AUDIO_H
#define AUDIO_H

typedef struct ma_engine ma_engine;
typedef struct ma_sound  ma_sound;

typedef struct {
    ma_sound* handle;
    int       playing;
    int       looping;
    float     volume;
    float     pitch;
} Sound;

// Engine lifecycle
int   audio_init(void);
void  audio_shutdown(void);

// Sound lifecycle
Sound* audio_load(const char* filepath);
void   audio_destroy(Sound* sound);

// Playback control
int   audio_play(Sound* sound);
int   audio_stop(Sound* sound);
int   audio_pause(Sound* sound);
int   audio_resume(Sound* sound);

// Properties
int   audio_is_playing(Sound* sound);
int   audio_is_looping(Sound* sound);
void  audio_set_looping(Sound* sound, int loop);
float audio_get_volume(Sound* sound);
void  audio_set_volume(Sound* sound, float volume);
float audio_get_pitch(Sound* sound);
void  audio_set_pitch(Sound* sound, float pitch);

// Master volume
float audio_get_master_volume(void);
void  audio_set_master_volume(float volume);

#endif // AUDIO_H
