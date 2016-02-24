package;

import flash.events.EventDispatcher;

class Parser
{
	public static var NAME : String = "LEVEL_PARSER";
	
	private var classesPath : String;
	
	/*
	 * Constructor
	 */
	public function new(classesPath : String = "") 
	{
		this.classesPath = classesPath;
	}
	
	/**
		Parses a XML file into a desired data structure.

		By default it assumes every line has its own parser. 
		
		ie: <classname> ... </classname>
		where `classname` is actually a class that inherits from LevelParser (directly) so each node can have its own parser.
		
		In order to make this work, it's necessary to have :
		
		<haxeflag name="--macro" value="include('classPath')" />
		
		in the Application.xml file
	**/
	public function Parse(xml : Xml) : Array<Parser>
	{
		var parser : Dynamic;
		var resClass : Class<Dynamic>;
		var classPath, className : String;
		var parsers, auxParsers : Array<Parser>;
		
		parsers = new Array<Parser>();
		
		try
		{	
			for (e in xml.iterator())
			{
				if (e.nodeType == Xml.Element)
				{
					className = e.nodeName.substring(0, 1).toUpperCase() + e.nodeName.substring(1, e.nodeName.length).toLowerCase();
					classPath = xml.get("classpath") == null ? classesPath : xml.get("classpath");
					resClass = Type.resolveClass(classPath + "." + className);
					
					if (resClass != null)
					{
						parser = Type.createInstance(resClass, []);
						if (Std.is(parser, Parser))
						{
							auxParsers = cast(parser, Parser).Parse(e);
							for (p in auxParsers)
								parsers.push(p);
							
							parsers.push(parser);
						}
					}
				}
			}
		}
		catch (e : String)
		{
			trace(e);
		}
		
		return parsers;
	}
}