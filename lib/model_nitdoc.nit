module model_nitdoc

import modelbuilder
import exprbuilder
import abstract_compiler

redef class MClass

	# All parents of classdef
	fun parents: HashSet[MClass] do
		var l_parents = new HashSet[MClass]
		for mclassdef in self.mclassdefs
		do
			for parent in mclassdef.in_hierarchy.greaters
			do
				if parent is mclassdef or l_parents.has(parent.mclass) then continue
				l_parents.add(parent.mclass)
			end
		end
		return l_parents
	end

	# All subclasses of classdef
	fun sub_classes: HashSet[MClass] do
		var l_sub_classes = new HashSet[MClass]
		for mclassdef in self.mclassdefs
		do
			for sub in mclassdef.in_hierarchy.smallers
			do
				if sub is mclassdef or l_sub_classes.has(sub.mclass) then continue
				l_sub_classes.add(sub.mclass)
			end
		end
		return l_sub_classes
	end

	# Return in which MModule classdef is refine
	fun refineds(mmodule: MModule): HashSet[MModule] do
		var l_refineds = new HashSet[MModule]
		mmodule.linearize_mclassdefs(self.mclassdefs)
		for refine in mclassdefs
		do
			if refine is self.mclassdefs.first then continue
			l_refineds.add(refine.mmodule)
		end
		return l_refineds
	end
end

redef class AClassdef
	
	# Return all constructors in self
	fun get_constructors: HashMap[MProperty, APropdef] do
		var l_constructors = new HashMap[MProperty, APropdef]
		for mproperty, apropdef in self.mprop2npropdef
		do
			if mproperty isa MMethod then
				var mmethod: MMethod = mproperty
				if mmethod.is_init then l_constructors[mproperty] = apropdef
			end
		end
		return l_constructors
	end

	# Return all methods in self
	fun get_methods: HashMap[MProperty, APropdef] do
		var l_methods = new HashMap[MProperty, APropdef]
		for mproperty, apropdef in self.mprop2npropdef
		do
			if not get_constructors.has_key(mproperty) then l_methods[mproperty] = apropdef
		end

		return l_methods
	end

end
