import modelbuilder
import exprbuilder
import abstract_compiler

class Nitdoc
	var toolcontext = new ToolContext
	var model = new Model
	var modelbuilder: ModelBuilder
	var arguments: Array[String]
	var prog: nullable String
	var main: nullable MModule
	var hmclasses: nullable HashMap[MClass, Set[MProperty]]
	var modules: nullable Array[MModule]
	var sorter: nullable MClassSorter[Object]
	
	init do
		toolcontext.process_options
		modelbuilder = new ModelBuilder(model, toolcontext)
		arguments = toolcontext.option_context.rest
		if arguments.is_empty or toolcontext.opt_help.value then
			toolcontext.option_context.usage
			return
		end
		prog = arguments.first
		hmclasses = new HashMap[MClass, Set[MProperty]]
		modules = new Array[MModule]
	end

	fun run_process_to_get_modules do
		modules = modelbuilder.parse_and_build([prog.as(not null)])
		modelbuilder.full_propdef_semantic_analysis
	end

	# Associate classes to their properties in a HashMap
	fun save_classes_and_prop(mmodule: MModule) do
		hmclasses = new HashMap[MClass, Set[MProperty]]
		for cl in mmodule.mclassdefs do hmclasses[cl.mclass] =  mmodule.properties(cl.mclass)
	end

	private fun properties_info(cl: MClass, prop: MProperty): String do
		var str = "{prop.to_s}:".under_line
		var cl_intro = prop.intro_mclassdef.mclass
		var properties = new Array[MPropDef]
		for red in prop.mpropdefs do
			str += "\n\t\t\t"
			if red.is_intro then
				str += "Defined by "
			else
				str += "Refined in "
			end	
			str += red.add_visibility_color
		end
		return str
	end
	
	fun process do
		if prog is null then return
		run_process_to_get_modules
		for mmodule in model.mmodules do
			save_classes_and_prop(mmodule)
			var classes = mmodule.mclassdefs
			print "----------------------------------------------------"
			print "Module :: {mmodule.to_s.green}"
			print "----------------------------------------------------\n\n"
			var i = 1
			for cl in classes do
				var curclass = cl.mclass
				print "\t{i.to_s}) {curclass.to_s.under_line}"
				curclass.print_defined_by
				curclass.print_parent
				curclass.print_refined(mmodule)
				curclass.print_sub_class

				var arrProp = hmclasses[curclass].to_a
				for p in arrProp do print "\n\t\t- {properties_info(curclass,p)}"	
				print "\n----------------------------------------------------\n"
				i+=1
			end
		end
		print_legend
	end
	
	private fun print_legend do	
		print "\nLEGEND".under_line
		print "\tpublic".green
		print "\tprotected".yellow
		print "\tprivate".red
		print "\tnone".red
	end
end

# Redef String class to add a function to color the string
redef class String
	private fun add_escape_char(escapechar: String): String do return "{escapechar}{self}{esc}[0m"
	private fun esc: Char do return 27.ascii
	private fun red: String do return add_escape_char("{esc}[1;31m")
	private fun yellow: String do return add_escape_char("{esc}[1;33m")
	private fun green: String do return add_escape_char("{esc}[1;32m")
	private fun blue: String do return add_escape_char("{esc}[1;34m")
	private fun cyan: String do return add_escape_char("{esc}[1;36m")
	private fun bold: String do return add_escape_char("{esc}[1m")
	private fun under_line: String do return add_escape_char("{esc}[4m")
end

class MClassSorter[E: Object]
	super AbstractSorter[E]
	redef fun compare(a, b) do
		var sa: String
		var sb: String
		var d = _dico
		if d.has_key(a) then
			sa = d[a]
		else
			sa = a.to_s
			d[a]= sa
		end
		if d.has_key(b) then
			sb = d[b]
		else
			sb = b.to_s
			d[b] = sb
		end
		return sa <=> sb
	end

	var _dico: HashMap[Object, String] = new HashMap[Object, String]
	init do end
end

redef class MPropDef
	# Attribuate a color in terms of the visibility of the property
	fun add_visibility_color: String do
		var str = ""
		if self.mproperty.visibility is public_visibility then
			str = self.full_path.green
		else if self.mproperty.visibility is protected_visibility then
			str = self.full_path.yellow
		else
			str = self.full_path.red
		end
		return str
	end

	# Get the full of a property
	fun full_path: String do
		var str = self.to_s.split_with("#")
		str.remove_at(str.length-1)
		return str.join("::")
	end
end

redef class MClass
	
	# Print in which MModule is define this MClass
	fun print_defined_by do print "\tDefined by the module {intro_mmodule.to_s.green}\n"

	# Print all parents of itself
	fun print_parent do
		var lst = new HashSet[MClass]
		print "\t\tPARENTS:".under_line
		for mclassdef in self.mclassdefs do
			for parent in mclassdef.in_hierarchy.greaters do
				if parent is mclassdef or lst.has(parent.mclass )then continue
				lst.add(parent.mclass)
				print "\t\t\t{parent.mclass.to_s}"
			end
		end
	end
	
	# Print all sub-classes
	fun print_sub_class do
		print "\t\tSUBCLASSES:".under_line
		var lst = new HashSet[MClass]
		for mclassdef in self.mclassdefs do
			for sub in mclassdef.in_hierarchy.smallers do
				if sub is mclassdef or lst.has(sub.mclass) then continue
				lst.add(sub.mclass)
				print "\t\t\t{sub.mclass.to_s}"
			end
		end
	end
	
	# Print in which MModule this MClass is redefines
	fun print_refined(mmodule: MModule) do
		print "\t\tREDEF:".under_line
		mmodule.linearize_mclassdefs(self.mclassdefs)
		for red in mclassdefs do
			if red is self.mclassdefs.first then continue
			print "\t\t\tRefined in the module {red.mmodule}"
		end
	end
end


class Html
	var file: OFStream
	init(filename: String) do
		self.file = new OFStream.open(filename)
	end

end

var read = new Nitdoc
read.process
