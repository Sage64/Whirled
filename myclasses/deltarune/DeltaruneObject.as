


package deltarune
{

import gamemaker.*;
import deltarune.objects.*;

public class DeltaruneObject extends GMObject
{
    public function DeltaruneObject()
    {
        super();
        
    }
    
    public function snd_play( _sound )
    {
        return audio_play_sound( _sound, false  );
    }
    
    public function snd_pitch( _sound, _pitch = 1 )
    {
        
        return null;
    }
    
}


}