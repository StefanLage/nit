# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Copyright 2008 Jean Privat <jean@pryen.org>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module ni_web

import model_utils
import html
import abstract_compiler

class Nitdoc
	private var toolcontext: ToolContext
	private var model: Model
	private var modelbuilder: ModelBuilder
	private var mainmodule: MModule
	private var arguments: Array[String]
	# Directory where will be generated the nitdoc
	# By default it's generated in current_path/nitdoc
	var destinationdir: nullable String
	var sharedir: nullable String
	
	private var opt_dir = new OptionString("Directory where doc is generated", "-d", "--dir")
	private var opt_source = new OptionString("What link for source (%f for filename, %l for first line, %L for last line)", "--source")
	private var opt_sharedir = new OptionString("Directory containing the nitdoc files", "--sharedir")
	private var opt_nodot = new OptionBool("Do not generate graphes with graphiviz", "--no-dot")

	init(toolcontext: ToolContext) do
		# We need a model to collect stufs
		self.toolcontext = toolcontext
		self.arguments = toolcontext.option_context.rest
		toolcontext.option_context.add_option(opt_dir)
		toolcontext.option_context.add_option(opt_source)
		toolcontext.option_context.add_option(opt_sharedir)
		toolcontext.option_context.add_option(opt_nodot)

		process_options

		if arguments.length > 2 then
			toolcontext.option_context.usage
			exit(1)
		end

		model = new Model
		modelbuilder = new ModelBuilder(model, toolcontext)
		
		# Here we load an process std modules
		var mmodules = modelbuilder.parse_and_build([arguments.first])
		if mmodules.is_empty then return
		modelbuilder.full_propdef_semantic_analysis
		assert mmodules.length == 1
		self.mainmodule = mmodules.first
	end
	
	fun start do
		if arguments.length == 1 then
			# Create destination dir if it's necessary
			if not destinationdir.file_exists then destinationdir.mkdir
			sys.system("cp -r {sharedir.to_s}/* {destinationdir.to_s}/")
			overview
			fullindex
			modules
			classes
		end
	end

	private fun process_options do
		if not opt_dir.value is null then
			destinationdir = opt_dir.value
		else
			destinationdir = "nitdoc_directory"
		end
		if not opt_sharedir.value is null then
			sharedir = opt_sharedir.value
		else
			var dir = "NIT_DIR".environ
			if dir.is_empty then
				dir = "{sys.program_name.dirname}/../share/nitdoc"
			else
				dir = "{dir}/share/nitdoc"
			end
			sharedir = dir
			if sharedir is null then
				print "Error: Cannot locate nitdoc share files. Uses --sharedir or envvar NIT_DIR"
				abort
			end
			dir = "{sharedir.to_s}/scripts/js-facilities.js"
			if sharedir is null then
				print "Error: Invalid nitdoc share files. Check --sharedir or envvar NIT_DIR"
				abort
			end
		end
	end
	
	fun overview do
		var overviewpage = new NitdocOverview.with(modelbuilder.nmodules, self.opt_nodot.value, destinationdir.to_s)
		overviewpage.save("{destinationdir.to_s}/index.html")
	end

	fun fullindex do
		var fullindex = new NitdocFullindex.with(model.mmodules)
		fullindex.save("{destinationdir.to_s}/full-index.html")
	end
	
	fun modules do
		for mod in modelbuilder.nmodules do
			var modulepage = new NitdocModules.with(mod)
			modulepage.save("{destinationdir.to_s}/{mod.mmodule.name}.html")
		end
	end

	fun classes do
		for amodule in modelbuilder.nmodules do
			for mclass, aclassdef in amodule.mclass2nclassdef do
				var classpage = new NitdocMClasses.with(mclass, aclassdef)
				classpage.save("{destinationdir.to_s}/{mclass.name}.html")
			end
		end
	end

end

class NitdocOverview
	super HTMLPage

	var amodules: Array[AModule]

	init with(modules: Array[AModule], opt_nodot: Bool, destination: String) do
		self.amodules = modules
		self.opt_nodot = opt_nodot
		self.destinationdir = destination
	end
	
	redef fun head do
		super
		add("title").text("Overview | Nit Standard Library")
	end

	redef fun header do
		open("header")
		open("nav").add_class("main")
		open("ul")
		add("li").add_class("current").text("Overview")
		open("li")
		add_html("<a href=\"full-index.html\">Full Index</a>")
		close("li")
		open("li")
		add_html("<a href=\"help.html\">Help</a>")
		close("li")
		open("li").attr("id", "liGitHub")
		open("a").add_class("btn").attr("id", "logGitHub")
		add("img").attr("id", "imgGitHub").attr("src", "resources/icons/github-icon.png")
		close("a")
		open("div").add_class("popover bottom")
		add("div").add_class("arrow").text(" ")
		open("div").add_class("githubTitle")
		add("h3").text("Github Sign In")
		close("div")
		open("div")
		add("label").attr("id", "lbloginGit").text("Username")
		add("input").attr("id", "loginGit").attr("name", "login").attr("type", "text")
		open("label").attr("id", "logginMessage").text("Hello ")
		open("a").attr("id", "githubAccount")
		add("strong").attr("id", "nickName").text(" ")
		close("a")
		close("label")
		close("div")
		open("div")
		add("label").attr("id", "lbpasswordGit").text("Password")
		add("input").attr("id", "passwordGit").attr("name", "password").attr("type", "password")
		open("div").attr("id", "listBranches")
		add("label").attr("id", "lbBranches").text("Branch")
		add("select").add_class("dropdown").attr("id", "dropBranches").attr("name", "dropBranches").attr("tabindex", "1").text(" ")
		close("div")
		close("div")
		open("div")
		add("label").attr("id", "lbrepositoryGit").text("Repository")
		add("input").attr("id", "repositoryGit").attr("name", "repository").attr("type", "text")
		close("div")
		open("div")
		add("label").attr("id", "lbbranchGit").text("Branch")
		add("input").attr("id", "branchGit").attr("name", "branch").attr("type", "text")
		close("div")
		open("div")
		add("a").attr("id", "signIn").text("Sign In")
		close("div")
		close("div")
		close("li")
		close("ul")
		close("nav")
		close("header")
	end

	redef fun body do
		super
		open("div").add_class("page")
		open("div").add_class("content fullpage")
		add("h1").text("Nit Standard Library")
		open("article").add_class("overview")
		add("p").text("Documentation for the standard library of Nit")
		add("p").text("Version jenkins-component=stdlib-19")
		add("p").text("Date: {sys.system("date").to_s}")
		close("article")
		open("article").add_class("overview")
		add("h2").text("Modules")
		open("ul")
		add_modules
		close("ul")
		process_generate_dot
		close("article")
		close("div")
		close("div")
		add("footer").text("Nit standard library. Version jenkins-component=stdlib-19.")
	end

	fun add_modules do
		for amodule in amodules do
			open("li")
			add("a").attr("href", "{amodule.mmodule.name}.html").text("{amodule.mmodule.to_s}")
			add_html(amodule.comment)
			close("li")
		end
	end
	
	fun process_generate_dot do
		var op = new Buffer
		op.append("digraph dep \{ rankdir=BT; node[shape=none,margin=0,width=0,height=0,fontsize=10]; edge[dir=none,color=gray]; ranksep=0.2; nodesep=0.1;\n")
		for amodule in amodules do
			op.append("\"{amodule.mmodule.name}\"[URL=\"{amodule.mmodule.name}.html\"];\n")
			for mmodule2 in amodule.mmodule.in_importation.direct_greaters do
				op.append("\"{amodule.mmodule.name}\"->\"{mmodule2.name}\";\n")
			end
		end
		op.append("\}\n")
		generate_dot(op.to_s, "dep", "Modules hierarchy")
	end
end

class NitdocFullindex
	super HTMLPage

	var mmodules: Array[MModule]

	init with(mmodules: Array[MModule]) do
		self.mmodules = mmodules
		opt_nodot = false
		destinationdir = ""
	end

	redef fun head do
		super
		add("title").text("Full Index | Nit Standard Library")
	end

	redef fun header do
		open("header")
		open("nav").add_class("main")
		open("ul")
		open("li")
		add_html("<a href=\"index.html\">Overview</a>")
		close("li")
		add("li").add_class("current").text("Full Index")
		open("li")
		add_html("<a href=\"help.html\">Help</a>")
		close("li")
		open("li").attr("id", "liGitHub")
		open("a").add_class("btn").attr("id", "logGitHub")
		add("img").attr("id", "imgGitHub").attr("src", "resources/icons/github-icon.png")
		close("a")
		open("div").add_class("popover bottom")
		add("div").add_class("arrow").text(" ")
		open("div").add_class("githubTitle")
		add("h3").text("Github Sign In")
		close("div")
		open("div")
		add("label").attr("id", "lbloginGit").text("Username")
		add("input").attr("id", "loginGit").attr("name", "login").attr("type", "text")
		open("label").attr("id", "logginMessage").text("Hello ")
		open("a").attr("id", "githubAccount")
		add("strong").attr("id", "nickName").text(" ")
		close("a")
		close("label")
		close("div")
		open("div")
		add("label").attr("id", "lbpasswordGit").text("Password")
		add("input").attr("id", "passwordGit").attr("name", "password").attr("type", "password")
		open("div").attr("id", "listBranches")
		add("label").attr("id", "lbBranches").text("Branch")
		add("select").add_class("dropdown").attr("id", "dropBranches").attr("name", "dropBranches").attr("tabindex", "1").text(" ")
		close("div")
		close("div")
		open("div")
		add("label").attr("id", "lbrepositoryGit").text("Repository")
		add("input").attr("id", "repositoryGit").attr("name", "repository").attr("type", "text")
		close("div")
		open("div")
		add("label").attr("id", "lbbranchGit").text("Branch")
		add("input").attr("id", "branchGit").attr("name", "branch").attr("type", "text")
		close("div")
		open("div")
		add("a").attr("id", "signIn").text("Sign In")
		close("div")
		close("div")
		close("li")
		close("ul")
		close("nav")
		close("header")
	end

	redef fun body do
		super
		open("div").add_class("page")
		open("div").add_class("content fullpage")
		add("h1").text("Full Index")
		add_content
		close("div")
		close("div")
		add("footer").text("Nit standard library. Version jenkins-component=stdlib-19.")
	end

	fun add_content do
		module_column
		classes_column
		properties_column
	end

	# Add to content modules column
	fun module_column do
		open("article").add_class("modules filterable")
		add("h2").text("Modules")
		open("ul")
		for mmodule in mmodules do
			open("li")
			add("a").attr("href", "{mmodule.name}.html").text(mmodule.name)
			close("li")
		end
		close("ul")
		close("article")
	end

	# Add to content classes modules
	fun classes_column do
		open("article").add_class("classes filterable")
		add("h2").text("Classes")
		open("ul")
		
		for mclass in mmodules.first.imported_mclasses do
			open("li")
			add("a").attr("href", "{mclass.name}.html").text(mclass.name)
			close("li")
		end

		close("ul")
		close("article")
	end

	# Insert the properties column of fullindex page
	fun properties_column do
		open("article").add_class("properties filterable")
		add("h2").text("Properties")
		open("ul")
	
		for method in mmodules.first.imported_methods do
			if method.visibility is none_visibility or method.visibility is intrude_visibility then continue
			open("li").add_class("intro")
			add("span").attr("title", "introduction").text("I")
			add_html("&nbsp;")
			add("a").attr("href", "{method.local_class.name}.html").attr("title", "").text("{method.name} ({method.local_class.name})")
			close("li")
		end

		for method in mmodules.first.redef_methods do
			if method.visibility is none_visibility or method.visibility is intrude_visibility then continue
			open("li").add_class("redef")
			add("span").attr("title", "redefinition").text("R")
			add_html("&nbsp;")
			add("a").attr("href", "{method.local_class.name}.html").attr("title", "").text("{method.name} ({method.local_class.name})")
			close("li")
		end

		close("ul")
		close("article")
	end

end

class NitdocModules
	super HTMLPage
	
	var amodule: AModule
	var modulename: String
	init with(amodule: AModule) do
		self.amodule = amodule
		self.modulename = self.amodule.mmodule.name
		opt_nodot = false
		destinationdir = ""
	end

	redef fun head do
		super
		add("title").text("{modulename} module | Nit Standard Library")
	end

	redef fun header do
		open("header")
		open("nav").add_class("main")
		open("ul")
		open("li")
		add_html("<a href=\"index.html\">Overview</a>")
		close("li")
		add("li").add_class("current").text(modulename)
		open("li")
		add_html("<a href=\"full-index.html\" >Full Index</a>")
		close("li")
		open("li")
		add_html("<a href=\"help.html\">Help</a>")
		close("li")
		open("li").attr("id", "liGitHub")
		open("a").add_class("btn").attr("id", "logGitHub")
		add("img").attr("id", "imgGitHub").attr("src", "resources/icons/github-icon.png")
		close("a")
		open("div").add_class("popover bottom")
		add("div").add_class("arrow").text(" ")
		open("div").add_class("githubTitle")
		add("h3").text("Github Sign In")
		close("div")
		open("div")
		add("label").attr("id", "lbloginGit").text("Username")
		add("input").attr("id", "loginGit").attr("name", "login").attr("type", "text")
		open("label").attr("id", "logginMessage").text("Hello ")
		open("a").attr("id", "githubAccount")
		add("strong").attr("id", "nickName").text(" ")
		close("a")
		close("label")
		close("div")
		open("div")
		add("label").attr("id", "lbpasswordGit").text("Password")
		add("input").attr("id", "passwordGit").attr("name", "password").attr("type", "password")
		open("div").attr("id", "listBranches")
		add("label").attr("id", "lbBranches").text("Branch")
		add("select").add_class("dropdown").attr("id", "dropBranches").attr("name", "dropBranches").attr("tabindex", "1").text(" ")
		close("div")
		close("div")
		open("div")
		add("label").attr("id", "lbrepositoryGit").text("Repository")
		add("input").attr("id", "repositoryGit").attr("name", "repository").attr("type", "text")
		close("div")
		open("div")
		add("label").attr("id", "lbbranchGit").text("Branch")
		add("input").attr("id", "branchGit").attr("name", "branch").attr("type", "text")
		close("div")
		open("div")
		add("a").attr("id", "signIn").text("Sign In")
		close("div")
		close("div")
		close("li")
		close("ul")
		close("nav")
		close("header")
	end

	redef fun body do
		super
		open("div").add_class("page")
		add_content
		close("div")
		add("footer").text("Nit standard library. Version jenkins-component=stdlib-19.")
	end

	# Insert all tags in content part
	fun add_content do
		open("div").add_class("content")
		add("h1").text(modulename)
		add("div").add_class("subtitle").text("module {modulename}")
		add_module_comment
		add_classes
		close("div")
	end

	# Insert module comment in the content
	fun add_module_comment do
		var doc = amodule.comment
		open("div").attr("id", "description")
		add("pre").add_class("text_label").text(doc)
		add("textarea").add_class("edit").attr("rows", "1").attr("cols", "76").attr("id", "fileContent").text(" ")
		add("a").attr("id", "cancelBtn").text("Cancel")
		add("a").attr("id", "commitBtn").text("Commit")
		add("pre").add_class("text_label").attr("id", "preSave").attr("type", "2")
		close("div")
	end

	fun add_classes do
		open("div").add_class("module")
		open("article").add_class("classes filterable")
		add("h2").text("Classes")
		open("ul")

		for cl in amodule.mmodule.mclassdefs
		do
			var name = cl.mclass.name
			if cl.is_intro then
				open("li").add_class("intro")
				add("span").attr("title", "introduced in this module").text("I ")
			else
				open("li").add_class("redef")
				add("span").attr("title", "refined in this module").text("R ")
			end
			add("a").attr("href", "{name}.html").text(name)
			close("li")
		end
		close("ul")
		close("article")
		close("div")
	end

end

class NitdocMClasses
	super HTMLPage
	
	var mclass: MClass
	var aclassdef: AClassdef
	var public_owner: nullable MModule

	init with(mclass: MClass, aclassdef: AClassdef) do
		self.mclass = mclass
		self.aclassdef = aclassdef
		self.public_owner = mclass.intro_mmodule.public_owner
		opt_nodot = false
		destinationdir = ""
	end

	redef fun head do
		super
		add("title").text("{self.mclass.name} class | Nit Standard Library")
	end

	redef fun header do
		open("header")
		open("nav").add_class("main")
		open("ul")
		open("li")
		add_html("<a href=\"index.html\">Overview</a>")
		close("li")
		open("li")
		if public_owner is null then
			add_html("<a href=\"{mclass.intro_mmodule.name}.html\">{mclass.intro_mmodule.name}</a>")
		else
			add_html("<a href=\"{public_owner.name}.html\">{public_owner.name}</a>")
		end
		close("li")
		add("li").add_class("current").text(mclass.name)
		open("li")
		add_html("<a href=\"full-index.html\" >Full Index</a>")
		close("li")
		open("li")
		add_html("<a href=\"help.html\">Help</a>")
		close("li")
		open("li").attr("id", "liGitHub")
		open("a").add_class("btn").attr("id", "logGitHub")
		add("img").attr("id", "imgGitHub").attr("src", "resources/icons/github-icon.png")
		close("a")
		open("div").add_class("popover bottom")
		add("div").add_class("arrow").text(" ")
		open("div").add_class("githubTitle")
		add("h3").text("Github Sign In")
		close("div")
		open("div")
		add("label").attr("id", "lbloginGit").text("Username")
		add("input").attr("id", "loginGit").attr("name", "login").attr("type", "text")
		open("label").attr("id", "logginMessage").text("Hello ")
		open("a").attr("id", "githubAccount")
		add("strong").attr("id", "nickName").text(" ")
		close("a")
		close("label")
		close("div")
		open("div")
		add("label").attr("id", "lbpasswordGit").text("Password")
		add("input").attr("id", "passwordGit").attr("name", "password").attr("type", "password")
		open("div").attr("id", "listBranches")
		add("label").attr("id", "lbBranches").text("Branch")
		add("select").add_class("dropdown").attr("id", "dropBranches").attr("name", "dropBranches").attr("tabindex", "1").text(" ")
		close("div")
		close("div")
		open("div")
		add("label").attr("id", "lbrepositoryGit").text("Repository")
		add("input").attr("id", "repositoryGit").attr("name", "repository").attr("type", "text")
		close("div")
		open("div")
		add("label").attr("id", "lbbranchGit").text("Branch")
		add("input").attr("id", "branchGit").attr("name", "branch").attr("type", "text")
		close("div")
		open("div")
		add("a").attr("id", "signIn").text("Sign In")
		close("div")
		close("div")
		close("li")
		close("ul")
		close("nav")
		close("header")
	end

	redef fun body do
		super
		open("div").add_class("page")
		add_content
		close("div")
		add("footer").text("Nit standard library. Version jenkins-component=stdlib-19.")
	end

	# Insert all tags in content part
	fun add_content do
		open("div").add_class("menu")
		properties_column
		inheritance_column
		close("div")	
		open("div").add_class("content")
		content
		close("div")
	end
	
	fun properties_column do
		open("nav").add_class("properties filterable")
		add("h3").text("Properties")
		
		if mclass.virtual_types.length > 0 then
			add("h4").text("Virtual Types")
			open("ul")
			for prop in mclass.virtual_types do
				add_html("<li class=\"redef\"><span title=\"Redefined\">R</span><a href=\"{prop.link_anchor}\">{prop.name}</a></li>")
			end
			close("ul")
		end
		if mclass.constructors.length > 0 then
			add("h4").text("Constructors")
			open("ul")
			for prop in mclass.constructors do
				add_html("<li class=\"intro\"><span title=\"Introduced\">I</span><a href=\"{prop.link_anchor}\">{prop.name}</a></li>")
			end
			close("ul")
		end
		add("h4").text("Methods")
		open("ul")
		if mclass.intro_methods.length > 0 then
			for prop in mclass.intro_methods do
				if prop.visibility is public_visibility or prop.visibility is protected_visibility then add_html("<li class=\"intro\"><span title=\"Introduced\">I</span><a href=\"{prop.link_anchor}\">{prop.name}</a></li>")
			end
		end
		if mclass.inherited_methods.length > 0 then
			for prop in mclass.inherited_methods do
				if prop.visibility is public_visibility or prop.visibility is protected_visibility then add_html("<li class=\"inherit\"><span title=\"Inherited\">H</span><a href=\"{prop.link_anchor}\">{prop.name}</a></li>")
			end
		end
		if mclass.redef_methods.length > 0 then
			for prop in mclass.redef_methods do
				if prop.visibility is public_visibility or prop.visibility is protected_visibility then add_html("<li class=\"redef\"><span title=\"Refined\">R</span><a href=\"{prop.link_anchor}\">{prop.name}</a></li>")
			end
		end
		close("ul")
		close("nav")
	end

	fun inheritance_column do
		open("nav")
		add("h3").text("Inheritance")
		if mclass.parents.length > 0 then
			add("h4").text("Superclasses")
			open("ul")
			for sup in mclass.parents do add_html("<li><a href=\"{sup.name}.html\">{sup.name}</a></li>")
			close("ul")
		end

		if mclass.descendants.length is 0 then
			add("h4").text("No Known Subclasses")
		else if mclass.descendants.length <= 100 then
			add("h4").text("Subclasses")
			open("ul")
			for sub in mclass.descendants do add_html("<li><a href=\"{sub.name}\">{sub.name}</a></li>")
			close("ul")
		else if mclass.children.length <= 100 then
			add("h4").text("Direct Subclasses Only")
			open("ul")
			for sub in mclass.children do add_html("<li><a href=\"{sub.name}\">{sub.name}</a></li>")
			close("ul")
		else
			add("h4").text("Too much Subclasses to list")
		end
		close("nav")
	end

	fun content do
		var subtitle = ""
		var lmmodule = new List[MModule]
		# Insert the subtitle part
		add("h1").text(mclass.name)
		open("div").add_class("subtitle")
		if mclass.visibility is none_visibility then subtitle += "private "
		subtitle += "{mclass.kind} <a href=\"{mclass.public_owner.name}.html\">{mclass.public_owner.name}</a>::{mclass.name}"
		add_html(subtitle)
		close("div")

		# We add the class description
		add_html("<div style=\"float: right;\"><a id=\"lblDiffCommit\"></a></div>")

		# We add the class description
		open("section").add_class("description")
		add_html("<pre class=\"text_label\" title=\"122\" name=\"\" tag=\"{mclass.mclassdefs.first.location.to_s}\" type=\"2\">Toto </pre><textarea id=\"fileContent\" class=\"edit\" cols=\"76\" rows=\"1\" style=\"display: none;\"></textarea><a id=\"cancelBtn\" style=\"display: none;\">Cancel</a><a id=\"commitBtn\" style=\"display: none;\">Commit</a><pre id=\"preSave\" class=\"text_label\" type=\"2\"></pre>")
		close("section")

		open("section").add_class("concerns")
		add("h2").add_class("section-header").text("Concerns")
		open("ul")
		for mmodule in mclass.mmodules do
			open("li")
			add_html("<a href=\"#MOD_{mmodule.name}\">{mmodule.name}</a>")
			open("ul")
			for nmodule in mmodule.in_nesting.direct_smallers do
				if nmodule is mmodule then continue
				if not lmmodule.has(nmodule) then
					lmmodule.add(nmodule)
					add_html("<li><a href=\"#MOD{nmodule.name}\">{nmodule.name}</a></li>")
				end
			end
			close("ul")
			close("li")
		end
		close("ul")
		close("section")

	end

end

redef class HTMLPage
	var opt_nodot: Bool
	var destinationdir : String	
		
	redef fun head do
		add("meta").attr("charset", "utf-8")
		add("script").attr("type", "text/javascript").attr("src", "scripts/jquery-1.7.1.min.js")
		add("script").attr("type", "text/javascript").attr("src", "quicksearch-list.js")
		add("script").attr("type", "text/javascript").attr("src", "scripts/js-facilities.js")
		add("link").attr("rel", "stylesheet").attr("href", "styles/main.css").attr("type", "text/css").attr("media", "screen")
	end
	
	redef fun body do header
	fun header do end
	
	# Generate a clickable graphviz image using a dot content
	fun generate_dot(dot: String, name: String, alt: String) do
		if opt_nodot then return
		var file = new OFStream.open("{self.destinationdir}/{name}.dot")
		file.write(dot)
		file.close
		sys.system("\{ test -f {self.destinationdir}/{name}.png && test -f {self.destinationdir}/{name}.s.dot && diff {self.destinationdir}/{name}.dot {self.destinationdir}/{name}.s.dot >/dev/null 2>&1 ; \} || \{ cp {self.destinationdir}/{name}.dot {self.destinationdir}/{name}.s.dot && dot -Tpng -o{self.destinationdir}/{name}.png -Tcmapx -o{self.destinationdir}/{name}.map {self.destinationdir}/{name}.s.dot ; \}")
		open("article").add_class("graph")
			add("img").attr("src", "{name}.png").attr("usemap", "#{name}").attr("style", "margin:auto").attr("alt", "{alt}")
		close("article")
		var fmap = new IFStream.open("{self.destinationdir}/{name}.map")
		add_html(fmap.read_all)
		fmap.close
	end
end

redef class AModule
	private fun comment: String do
		var ret = ""
		if n_moduledecl is null or n_moduledecl.n_doc is null then ret
		if n_moduledecl.n_doc is null then return ""
		for t in n_moduledecl.n_doc.n_comment do
			ret += "{t.text.replace("# ", "")}"
		end
		return ret
	end
end

redef class MModule
	
	# Get the list of all methods in a module
	fun imported_methods: Set[MMethod] do
		var methods = new HashSet[MMethod]
		for mclass in imported_mclasses do
			for method in mclass.intro_methods do
				methods.add(method)
			end
		end
		return methods
	end
	
	# Get the list aof all refined methods in a module
	fun redef_methods: Set[MMethod] do
		var methods = new HashSet[MMethod]
		for mclass in redef_mclasses do
			for method in mclass.intro_methods do
				methods.add(method)
			end
		end
		return methods
	end
end

redef class MClass

	fun public_owner: MModule do
		var owner = intro_mmodule
		if owner.public_owner is null then
			return owner
		else
			return owner.public_owner.as(not null)
		end
	end

	fun mmodules: Set[MModule] do
		var mdls = new HashSet[MModule]
		for mclassdef in mclassdefs do mdls.add(mclassdef.mmodule)
		return mdls
	end
end

redef class MProperty
	fun local_class: MClass do
		var classdef = self.intro_mclassdef
		return classdef.mclass
	end

	fun class_text: String do
		var str = full_name.split("::")
		return str[2]
	end

	fun link_anchor: String do
		return "{class_text}.html#{anchor}"
	end

	fun anchor: String do
		return "PROP_{c_name}"
	end
end

redef class APropdef
	private fun short_comment: String is abstract
end

redef class AAttrPropdef
	redef fun short_comment do
		var ret = ""
		if n_doc != null then
			var txt = n_doc.n_comment.first.text
			txt = txt.replace("# ", "")
			txt = txt.replace("\n", "")
			ret += txt
		end
		return ret
	end
end

redef class AMethPropdef
	redef fun short_comment do
		var ret = ""
		if n_doc != null then
			var txt = n_doc.n_comment.first.text
			txt = txt.replace("# ", "")
			txt = txt.replace("\n", "")
			ret += txt
		end
		return ret
	end
end

# Create a tool context to handle options and paths
var toolcontext = new ToolContext
toolcontext.process_options

# Here we launch the nit index
var nitdoc = new Nitdoc(toolcontext)
nitdoc.start

