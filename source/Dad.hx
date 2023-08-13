package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

class Dad extends Character
{
	public var stunned:Bool = false;

	public var sprTracker:FlxSprite;
    public static var boyfriend:Boyfriend;

	public function new(x:Float, y:Float, ?char:String = 'dad')
	{
		super(x, y, char, true);
	}

	public var startedDeath:Bool = false;

	override function update(elapsed:Float)
	{
		if (!debugMode)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}
			else
				holdTimer = 0;

			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
			{
				playAnim('idle', true, false, 10);
			}

			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished && startedDeath)
			{
				boyfriend.playAnim('deathLoop');
			}
		}

		super.update(elapsed);

		if (sprTracker != null)
		{
			x = (sprTracker.y * 2) + 90 - 350;
			y = FlxG.height / 3 - 68;
		}		
	}
}
