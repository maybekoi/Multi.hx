package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
//import io.newgrounds.NG;
import Controls.KeyboardScheme;
import lime.app.Application;
import onlinemod.OnlineMenuState;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = ['online', 'options'];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var scrollTxt:FlxSprite;

	var engineVer:String = "1.2.1";
	var onlineVer:String = "BETA VERSION";

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Main Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		
		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('klaskiiLoop'));

		//}

		/*
		if (FlxG.sound.music.playing)
		{
			FlxG.sound.music.stop();
			FlxG.sound.playMusic(Paths.music('klaskiiLoop'));
		}
		else
		{
			FlxG.sound.playMusic(Paths.music('klaskiiLoop'));
			// klaskiiLoop pog
		}
		*/

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.loadImage('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.loadImage('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		scrollTxt = new FlxText(0, FlxG.height - 0, 0, "Test thing I guess", 12);
		scrollTxt.antialiasing = true;
		scrollTxt.screenCenter();
		scrollTxt.y = 0;
		scrollTxt.scrollFactor.x = 0;
		scrollTxt.scrollFactor.y = 0;
		add(scrollTxt);

		var mf:FlxSprite = new FlxSprite(-80).loadGraphic('assets/images/mainmenu/menuframes.png');
		mf.scrollFactor.x = 0;
		mf.scrollFactor.y = 0;
		mf.setGraphicSize(Std.int(mf.width * 1));
		mf.updateHitbox();
		mf.screenCenter();
		mf.antialiasing = true;
		add(mf);

		var t1:FlxSprite = new FlxSprite(-80).loadGraphic('assets/images/mainmenu/triangles1.png');
		t1.scrollFactor.x = 0;
		t1.scrollFactor.y = 0;
		t1.setGraphicSize(Std.int(t1.width * 1));
		t1.updateHitbox();
		t1.screenCenter();
		t1.antialiasing = true;
		add(t1);

		var t2:FlxSprite = new FlxSprite(-80).loadGraphic('assets/images/mainmenu/triangles2.png');
		t2.scrollFactor.x = 0;
		t2.scrollFactor.y = 0;
		t2.setGraphicSize(Std.int(t2.width * 1));
		t2.updateHitbox();
		t2.screenCenter();
		t2.antialiasing = true;
		add(t2);

		var t3:FlxSprite = new FlxSprite(-80).loadGraphic('assets/images/mainmenu/triangles3.png');
		t3.scrollFactor.x = 0;
		t3.scrollFactor.y = 0;
		t3.setGraphicSize(Std.int(t3.width * 1));
		t3.updateHitbox();
		t3.screenCenter();
		t3.antialiasing = true;
		add(t3);

		var t4:FlxSprite = new FlxSprite(-80).loadGraphic('assets/images/mainmenu/triangles4.png');
		t4.scrollFactor.x = 0;
		t4.scrollFactor.y = 0;
		t4.setGraphicSize(Std.int(t4.width * 1));
		t4.updateHitbox();
		t4.screenCenter();
		t4.antialiasing = true;
		add(t4);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "FUNKIN " + Application.current.meta.get('version') + " | FX Engine " + engineVer, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		var versionShit2:FlxText = new FlxText(15, FlxG.height - 35, 0, "Multi.hx by TyDev " + onlineVer, 12);
		versionShit2.scrollFactor.set();
		versionShit2.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit2);

		// NG.core.calls.event.logEvent('swag').send();

		if (FlxG.save.data.zxnm)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					/*
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
					#else
					FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
					#end
					*/
					openURL('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'online':
										FlxG.switchState(new OnlineMenuState());	
									case 'options':
										//FlxTransitionableState.skipNextTransIn = true;
										//FlxTransitionableState.skipNextTransOut = true;
										FlxG.switchState(new OptionsMenu());
								}
							});
						}
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			/*
			spr.x = 20;
			// Nuh uh
			*/
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}