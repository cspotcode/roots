should = require 'should'
path = require 'path'
fs = require 'fs'
colors = require 'colors'
shell = require 'shelljs'
run = require('child_process').exec
root = path.join __dirname
basic_root = path.join root, 'basic'

# 
# command line interface
# 

# can't test watch because the process hangs - the internals of
# the watch command are tested below in the compiler section though

describe 'command', ->
  
  describe 'compile', -> # ----------------------------------------------------------------------

    before (done) ->
      run "cd #{basic_root}; ../../bin/roots compile", done

    it 'should compile files to /public', ->
      fs.readdirSync(path.join(basic_root, 'public')).should.have.lengthOf(5)

    it 'should minify all css and javascript', () ->
      js_content = fs.readFileSync path.join(basic_root, 'public/js/main.js'), 'utf8'
      js_content.should.not.match /\n/

    it 'should compile all files to public', ->
      css_content = fs.readFileSync path.join(basic_root, 'public/css/example.css'), 'utf8'
      css_content.should.not.match /\n/
      shell.rm '-rf', path.join(basic_root, 'public') 

  describe 'new', -> # -------------------------------------------------------------------------

    test_path = path.join(root, 'testproj')

    it 'should use the default template if no flags present', (done) ->
      run "cd #{root}; ../bin/roots new testproj", ->
        fs.existsSync(test_path).should.be.ok
        fs.existsSync(path.join(test_path, 'app.coffee')).should.be.ok
        fs.existsSync(path.join(test_path, 'readme.md')).should.be.ok
        fs.existsSync(path.join(test_path, 'views')).should.be.ok
        fs.existsSync(path.join(test_path, 'views/index.jade')).should.be.ok
        fs.existsSync(path.join(test_path, 'views/layout.jade')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/favicon.ico')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/css')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/css/_settings.styl')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/css/master.styl')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/js')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/js/main.coffee')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/js/_helper.coffee')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/js/pie.htc')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/js/require.js')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/img')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/img/noise.png')).should.be.ok
        shell.rm '-rf', path.join(root, 'testproj')
        done()

    it 'should use express template if the --express flag is present', (done) ->
      run "cd #{root}; ../bin/roots new testproj --express", ->
        fs.existsSync(test_path).should.be.ok
        fs.existsSync(path.join(test_path, 'app.js')).should.be.ok
        fs.existsSync(path.join(test_path, 'routes')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets')).should.be.ok
        fs.existsSync(path.join(test_path, 'views')).should.be.ok
        fs.existsSync(path.join(test_path, 'public')).should.be.ok
        shell.rm '-rf', path.join(root, 'testproj')
        done()

    it 'should use basic template if the --basic flag is present', (done) ->
      run "cd #{root}; ../bin/roots new testproj --basic", ->
        fs.existsSync(test_path).should.be.ok
        fs.existsSync(path.join(test_path, 'views/index.html')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/js/main.js')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/css/example.css')).should.be.ok
        shell.rm '-rf', path.join(root, 'testproj')
        done()

  describe 'plugin', -> # ---------------------------------------------------------------------

    it 'should create a template inside /plugins on \'generate\'', (done) ->
      run "cd #{basic_root}; ../../bin/roots plugin generate", ->
        fs.existsSync(path.join(basic_root, 'plugins/template.coffee')).should.be.ok
        shell.rm '-rf', path.join(basic_root, 'plugins')
        done()

    it 'should use the javascript template if called with --js', (done) ->
      run "cd #{basic_root}; ../../bin/roots plugin generate --js", ->
        fs.existsSync(path.join(basic_root, 'plugins/template.js')).should.be.ok
        shell.rm '-rf', path.join(basic_root, 'plugins')
        done()

  describe 'version', -> # ---------------------------------------------------------------------

    it 'should output the correct version number for roots', (done) ->
      version = JSON.parse(fs.readFileSync('package.json')).version
      run './bin/roots version', (err,out) ->
        out.replace(/\n/, '').should.eql(version)
        done()

  describe 'js', -> # --------------------------------------------------------------------------

    it 'should expose bower\'s interface', (done) ->
      run "cd #{basic_root}; ../../bin/roots js", (err,out, stdout) ->
        out.should.match /bower/
        done()

# 
# compiler
# 
 
describe 'compiler', ->

  compiler = null

  before ->
    Compiler = require path.join(root, '../lib/compiler')
    compiler = new Compiler()

  it 'eventemitter should be hooked up properly', (done) ->
    compiler.on 'finished', -> done()
    compiler.finish()

describe 'jade', ->

  jade_path = path.join root, 'sandbox/jade'

  it 'should compile jade view templates', (done) ->
    run "cd #{jade_path}; ../../../bin/roots compile --no-compress", ->
      fs.existsSync(path.join(jade_path, 'public/index.html')).should.be.ok
      shell.rm '-rf', path.join(jade_path, 'public')
      done()

describe 'ejs', ->

  ejs_path = path.join root, 'sandbox/ejs'

  it 'should compile ejs', (done) ->
    run "cd #{ejs_path}; ../../../bin/roots compile --no-compress", ->
      fs.existsSync(path.join(ejs_path, 'public/index.html')).should.be.ok
      shell.rm '-rf', path.join(ejs_path, 'public')
      done()

describe 'coffeescript', ->

  coffeescript_path = path.join root, 'sandbox/coffeescript'

  it 'should compile coffeescript', (done) ->
    run "cd #{coffeescript_path}; ../../../bin/roots compile --no-compress", ->
      fs.existsSync(path.join(coffeescript_path, 'public/basic.js')).should.be.ok
      # '#= require' test
      fs.existsSync(path.join(coffeescript_path, 'public/require.js')).should.be.ok
      require_content = fs.readFileSync path.join(coffeescript_path, 'public/require.js')
      require_content.should.match /BASIC/
      shell.rm '-rf', path.join(coffeescript_path, 'public')
      done()

  it 'should compile without closures when specified in app.coffee'
    # this needs a separate app.coffee file

describe 'stylus', ->
  it 'should compile stylus'
  it 'should make the roots css library available'
  it 'should include the project directory for requires'

describe 'static files', ->
  it 'should copy static files'

# 
# deploy
# 

describe 'deploy', ->
  deployer = null

  before ->
    Deployer = require path.join(root, '../lib/deployer')
    test_adapter = { test: (input)-> return input }
    deployer = new Deployer(test_adapter, '')
    deployer.add_shell_method('test');

  it 'handles adapters correctly', ->
    deployer.test(true).should.be.ok
    deployer.test(false).should.not.be.ok

  it 'has all the required shell methods', ->
    deployer.check_install_status.should.exist
    deployer.check_credentials.should.exist
    deployer.compile_project.should.exist
    deployer.add_config_files.should.exist
    deployer.commit_files.should.exist
    deployer.create_project.should.exist
    deployer.push_code.should.exist