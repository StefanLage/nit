import nitdoc_console
import html

class NitdocWeb
	super Nitdoc

	# Directory where will be generated the nitdoc
	# By default it's generated in current_path/nitdoc
	var destinationdir: nullable String
	var sharedir: nullable String

	private var opt_dir = new OptionString("Directory where doc is generated", "-d", "--dir")
	private var opt_source = new OptionString("What link for source (%f for filename, %l for first line, %L for last line)", "--source")
	private var opt_sharedir = new OptionString("Directory containing the nitdoc files", "--sharedir")
	private var opt_nodot = new OptionBool("Do not generate graphes with graphiviz", "--no-dot")

	init do 
		toolcontext.option_context.add_option(opt_dir)
		toolcontext.option_context.add_option(opt_source)
		toolcontext.option_context.add_option(opt_sharedir)
		toolcontext.option_context.add_option(opt_nodot)
		super
	end

	redef fun process do 
		if prog is null then return
		run_process_to_get_modules
		process_options
		# Create destination dir if it's necessary
		if not destinationdir.file_exists then destinationdir.mkdir
		sys.system("cp -r {sharedir.to_s}/* {destinationdir.to_s}/")
		
		# Generate HTML pages
		generate_overview
		generate_fullindex
	end
	
	private fun process_options do
		if not opt_dir.value is null then
			destinationdir = opt_dir.value
		else
			destinationdir = "nitdoc_dir"
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

	fun generate_overview  do
		var overviewpage = new NitdocOverview.with(model.mmodules, self.opt_nodot.value, destinationdir.to_s)
		overviewpage.save("{destinationdir.to_s}/index.html")
	end

	fun generate_fullindex do
		for mod in model.mmodules do save_classes_and_prop(mod)
		var fullindex = new NitdocFullindex.with(model.mmodules, hmclasses)
		fullindex.save("{destinationdir.to_s}/full-index.html")
	end

	redef fun save_classes_and_prop(mmodule: MModule) do
		for cl in mmodule.mclassdefs do hmclasses[cl.mclass] = mmodule.properties(cl.mclass)
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

class NitdocOverview
	super HTMLPage

	var mmodules: Array[MModule]

	init with(modules: Array[MModule], opt_nodot: Bool, destination: String) do
		self.mmodules = modules
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
		add("p").text("Documentation for the standard library of Nit<br/>Version jenkins-component=stdlib-19<br/>Date: Thu Jun 6 14:38:59 2013 -0400")
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
		for mmodule in mmodules
		do
			open("li")
			add("a").attr("href", "{mmodule.name}.html").text("{mmodule.to_s}")
			close("li")
		end
	end
	
	fun process_generate_dot do
		var op = new Buffer
		op.append("digraph dep \{ rankdir=BT; node[shape=none,margin=0,width=0,height=0,fontsize=10]; edge[dir=none,color=gray]; ranksep=0.2; nodesep=0.1;\n")
		for mmodule in mmodules
		do
			op.append("\"{mmodule.name}\"[URL=\"{mmodule.name}.html\"];\n")
			for mmodule2 in mmodule.in_importation.direct_greaters do
				op.append("\"{mmodule.name}\"->\"{mmodule2.name}\";\n")
			end
		end
		op.append("\}\n")
		generate_dot(op.to_s, "dep", "Modules hierarchy")
	end
end

class NitdocFullindex
	super HTMLPage

	var mmodules: Array[MModule]
	var hmclasses: nullable HashMap[MClass, Set[MProperty]]
	var lsproperties: nullable List[MProperty]

	init with(mmodules: Array[MModule], hmclasses: nullable HashMap[MClass, Set[MProperty]]) do
		self.mmodules = mmodules
		self.hmclasses = hmclasses
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
		lsproperties = new List[MProperty]
		for k, v in hmclasses.as(not null)
		do
			for prop in v
			do
				if lsproperties.has(prop) then continue
				lsproperties.push(prop)
			end
		end

		# Adding Modules column
		module_column
		classes_column
		properties_column
	end

	# Add to content modules column
	fun module_column do
		open("article").add_class("modules filterable")
		add("h2").text("Modules")
		open("ul")
		for mmodule in mmodules
		do
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
		for mclass in hmclasses.keys
		do
			open("li")
			add("a").attr("href", "{mclass.name}.html").text(mclass.name)
			close("li")
		end
		close("ul")
		close("article")
	end

	fun properties_column do
		open("article").add_class("properties filterable")
		add("h2").text("Properties")
		open("ul")
		for prop in lsproperties.as(not null)
		do
			if prop.intro isa MAttribute then continue

			open("li").add_class("intro")
			add("span").attr("title", "introduction").text("I")
			add_html("&nbsp;")
			add("a").attr("href", "{prop.local_class.name}.html").attr("title", "{prop.local_class.name}").text("{prop.name}&nbsp; ({prop.local_class.name})")
			close("li")
		end
		close("ul")
		close("article")
	end

end

redef class MProperty
	fun local_class: MClass do
		var classdef = self.intro_mclassdef
		return classdef.mclass
	end
end

var read = new NitdocWeb
read.process
