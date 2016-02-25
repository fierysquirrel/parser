package;

class Parser<E>
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
		
		We return an array of E which could be any time of element
	**/
	public function Parse(xml : Xml) : Array<E>
	{
		var parserInstance : Dynamic;
		var parser : Parser<E>;
		var resClass : Class<Dynamic>;
		var classPath, className : String;
		var elements, auxElements : Array<E>;
		
		elements = new Array<E>();
		
		try
		{	
			for (e in xml.iterator())
			{
				if (e.nodeType == Xml.Element)
				{
					className = e.get("classname") == null ? e.nodeName.substring(0, 1).toUpperCase() + e.nodeName.substring(1, e.nodeName.length).toLowerCase() : e.get("classname");
					classPath = xml.get("classpath") == null ? classesPath : xml.get("classpath");
					resClass = Type.resolveClass(classPath + "." + className);
					
					if (resClass != null)
					{
						parserInstance = Type.createInstance(resClass, [classesPath]);
						if (Std.is(parserInstance, Parser))
						{
							parser = cast parserInstance;
							auxElements = parser.Parse(e);
							for (p in auxElements)
								elements.push(p);
						}
					}
				}
			}
		}
		catch (e : String)
		{
			trace(e);
		}
		
		return elements;
	}
}