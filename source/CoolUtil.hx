package;

import flixel.FlxG;
import openfl.utils.Assets as OpenFlAssets;
import flixel.math.FlxMath;
#if VIDEOS
import hxcodec.VideoHandler;
#end
#if FEATURE_FILESYSTEM
import sys.io.File;
import Sys;
import sys.FileSystem;
#end
import haxe.io.Path;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['Easy', 'Normal', 'Hard'];
	public static var suffixDiffsArray:Array<String> = ['-easy', "", "-hard"];
	public static var defaultDifficulty:String = 'Normal'; // The chart that has no suffix and starting difficulty on Freeplay/Story Mode

	public static var difficulties:Array<String> = [];

	public static function difficultyFromInt(difficulty:Int):String
	{
		return difficultyArray[difficulty];
	}

	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if (num == null)
			num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num];
		if (fileSuffix != defaultDifficulty)
		{
			fileSuffix = '-' + fileSuffix;
		}
		else
		{
			fileSuffix = '';
		}
		return Paths.formatToSongPath(fileSuffix);
	}

	public static function difficultyString():String
	{
		return difficulties[PlayState.storyDifficulty].toUpperCase();
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		return Math.max(min, Math.min(max, value));
	}

	public static function fpsLerp(v1:Float, v2:Float, ratio:Float):Float
	{
		return FlxMath.lerp(v1, v2, getFPSRatio(ratio));
	}

	public static function getFPSRatio(ratio:Float):Float
	{
		return FlxMath.bound(ratio * 60 * FlxG.elapsed, 0, 1);
	}

	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static var daPixelZoom:Float = 6;

	public static function camLerpShit(lerp:Float):Float
	{
		return lerp * (FlxG.elapsed / (1 / 60));
	}

	/*
	 * just lerp that does camLerpShit for u so u dont have to do it every time
	 */
	public static function coolLerp(a:Float, b:Float, ratio:Float):Float
	{
		return FlxMath.lerp(a, b, camLerpShit(ratio));
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String>;

		try
		{
			daList = OpenFlAssets.getText(path).trim().split('\n');
		}
		catch (e)
		{
			daList = null;
		}

		if (daList != null)
			for (i in 0...daList.length)
			{
				daList[i] = daList[i].trim();
			}

		return daList;
	}

	public static function coolStringFile(path:String):Array<String>
	{
		var daList:Array<String> = path.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static var loadingVideos:Array<String> = [];
	public static var loadedVideos:Array<String> = [];

	public static function precacheVideo(name:String):Void
	{
		#if VIDEOS
		if (OpenFlAssets.exists(Paths.video(name)))
		{
			if (!loadedVideos.contains(name))
			{
				loadingVideos.push(name);
				var cache:VideoHandler = new VideoHandler();
				cache.canUseSound = false;
				cache.playVideo(Paths.video(name));
				cache.onOpening = function()
				{
					cache.stop();
					cache.dispose();
					loadedVideos.push(name);
					loadingVideos.remove(name);
				}
				FlxG.log.add('Video file has been cached: ' + name);
			}
			else
			{
				FlxG.log.add('Video file has already been cached: ' + name);
			}
		}
		else
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
		}
		#else
		FlxG.log.warn('Platform not supported!');
		#end
	}

	#if FEATURE_FILESYSTEM
	public static function findFilesInPath(path:String, extns:Array<String>, ?filePath:Bool = false, ?deepSearch:Bool = true):Array<String>
	{
		var files:Array<String> = [];

		if (FileSystem.exists(path))
		{
			for (file in FileSystem.readDirectory(path))
			{
				var path = haxe.io.Path.join([path, file]);
				if (!FileSystem.isDirectory(path))
				{
					for (extn in extns)
					{
						if (file.endsWith(extn))
						{
							if (filePath)
								files.push(path);
							else
								files.push(file);
						}
					}
				}
				else if (deepSearch) // ! YAY !!!! -lunar
				{
					var pathsFiles:Array<String> = findFilesInPath(path, extns);

					for (_ in pathsFiles)
						files.push(_);
				}
			}
		}
		return files;
	}

	public static inline function getFileStringFromPath(file:String):String
	{
		return Path.withoutDirectory(Path.withoutExtension(file));
	}
	#end
}
