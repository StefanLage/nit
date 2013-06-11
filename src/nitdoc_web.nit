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


	init do 
		toolcontext.option_context.add_option(opt_dir)
		toolcontext.option_context.add_option(opt_source)
		toolcontext.option_context.add_option(opt_sharedir)
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
		var overviewpage = new NitdocOverview.with(model.mmodules)
		overviewpage.save("{destinationdir.to_s}/index.html")
	end

end

redef class HTMLPage
	redef fun head do
		add("meta").attr("charset", "utf-8")
		add("script").attr("type", "text/javascript").attr("src", "scripts/jquery-1.7.1.min.js")
		add("script").attr("type", "text/javascript").attr("src", "quicksearch-list.js")
		add("script").attr("type", "text/javascript").attr("src", "scripts/js-facilities.js")
		add("link").attr("rel", "stylesheet").attr("href", "styles/main.css").attr("type", "text/css").attr("media", "screen")
	end

	redef fun body do header
	fun header do end
end

class NitdocOverview
	super HTMLPage

	var mmodules: Array[MModule]

	init with(modules: Array[MModule]) do self.mmodules = modules

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
		add("a").attr("href", "help.html").text("Help")
		close("li")
		open("li").attr("id", "liGitHub")
		open("a").add_class("btn").attr("id", "logGitHub")
		add("img").attr("id", "imgGitHub").attr("src", "resources/icons/github-icon.png")
		close("a")
		open("div").add_class("popover bottom")
		add("div").add_class("arrow").text(" ")
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
end


var read = new NitdocWeb
read.process
