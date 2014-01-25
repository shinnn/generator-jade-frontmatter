module.exports = (grunt) ->
  'use strict'

  path = require 'path'
  
  _ = require 'lodash'
  yfm = require 'assemble-front-matter'
  sizeOf = require 'image-size'
  jade = require 'jade'

  require('load-grunt-tasks') grunt, {pattern: [
    'grunt-*'
    '!grunt-gh-pages'
    '!grunt-prompt'
    '!grunt-open'
  ]}
  
  settings = grunt.file.readYAML 'settings.yaml'
  
  BIN = "#{ process.cwd() }/node_modules/.bin/"

  # Add '/' to the string if its last character is not '/'
  _addLastSlash = (str) ->
    if str.charAt(str.length - 1) is '/' or str is ''
      str
    else
      "#{ str }/"

  SRC_ROOT = _addLastSlash(settings.srcPath) or ''
  DEST_ROOT = _addLastSlash(settings.destPath) or 'site/'
  HOME_DIR = process.env.HOME or
    process.env.HOMEPATH or
    process.env.USERPROFILE
  
  JS_ROOT = "#{ SRC_ROOT }js/"
  
  grunt.initConfig
    bower:
      options:
        targetDir: "#{ DEST_ROOT }.tmp/bower_exports/"
        cleanTargetDir: true
      install:
        bowerOptions:
          production: true
      
    modernizr:
      devFile: 'remote'
      outputFile: "#{ SRC_ROOT }public/js/modernizr.js"
      extra:
        # Modernizr won't includes the HTML5 Shiv.
        # Instead, the Shiv will be included in the IE-fix script file.
        # It saves 2kb on modern browser.
        shiv: false
        printshiv: false
        mq: true
      extensibility:
        svg: true
        touch: true
        cssanimations: true
        rgba: true
  
    lodash:
      options:
        modifier: 'legacy'
        #include: []
        flags: ['--minify']
      custom:
        dest: "#{ JS_ROOT }vendor/lodash.gruntbuild.js"

    casperjs:
      files: ["#{ SRC_ROOT }casperjs/{,*/}*.{js,coffee}"]
      
    copy:
      public:
        files: [
          expand: true
          cwd: "#{ SRC_ROOT }public"
          src: ['**', '!**/{.DS_Store,Thumbs.db}']
          dest: DEST_ROOT
          dot: true
        ]
      bower:
        files: [
          expand: true
          cwd: '<%= bower.options.targetDir %>/public'
          src: ['**', '!**/{.DS_Store,Thumbs.db}']
          dest: "#{ DEST_ROOT }bower_components"
          dot: true
        ]
      bower_debug:
        files: [
          expand: true
          cwd: '<%= bower.options.targetDir %>/debug'
          src: ['**', '!**/{.DS_Store,Thumbs.db}']
          dest: "#{ DEST_ROOT }/debug/bower_components"
          dot: true
        ]

    compass:
      options:
        config: "#{ SRC_ROOT }scss/config.rb"
        cssDir: "#{ DEST_ROOT }debug/css-readable"
        environment: 'development'
      all: {}
    
    autoprefixer:
      all:
        src: '<%= compass.options.cssDir%>{,*/}*.css'
    
    cmq:
      all:
        options:
          log: true
        src: ['<%= compass.options.cssDir%>{,*/}*.css']
        dest: '<%= compass.options.cssDir%>'
      
    cssmin:
      dist:
        files: [
          expand: true
          cwd: '<%= compass.options.cssDir%>'
          src: ['{,*/}*.css']
          dest: "#{ DEST_ROOT }css/"
        ]
    
    csslint:
      lax:
        options:
          import: false
          ids: false
        src: ['<%= compass.readable.options.cssDir %>/*.css']
    
    coffee:
      options:
        sourceMap: true

      dev:
        options:
          bare: true
        src: ["#{ JS_ROOT }main/*.coffee"]
        dest: "#{ DEST_ROOT }debug/js/main.js"
      dist:
        src: ['js/main/*.coffee']
        dest: "#{ DEST_ROOT }.tmp/main.js"
    
    uglify:
      options:
        preserveComments: require 'uglify-save-license'
      
      main:
        options:
          banner: "/*! Copyright (c) 2014 #{ settings.author } | MIT License */"
          compress:
            global_defs:
              DEBUG: false
            dead_code: true
        src: '<%= coffee.dist.dest %>'
        dest: '<%= uglify.main.src %>'
      bower:
        options:
          compress:
            # For /*cc_on!*/ comments
            dead_code: false
        files: [
          expand: true
          cwd: '<%= bower.options.targetDir %>'
          src: [
            '{,*/,*/*/}*.js',
            '!{,*/,*/*/}*{.min,-min}.js', '!debug/{,*/}*.js'
          ]
          dest: '<%= bower.options.targetDir %>'
        ]
    
    concat:
      vendor:
        src: [
          "#{ JS_ROOT }vendor/{,*/}*.js"
          '<%= bower.options.targetDir %>{,*/,*/*/}*.js'
          '!<%= bower.options.targetDir %>{public,ie,debug}{,*/,*/*/}*.js'
        ]
        dest: "#{ DEST_ROOT }debug/js/vendor.js"
      vendor_ie:
        src: [
          "#{ JS_ROOT }vendor-ie/{,*/}*.js"
          '<%= bower.options.targetDir %>/ie/{,*/}*.js'
        ]
        dest: "#{ DEST_ROOT }js/vendor.ie.js"
      main:
        src: ["#{ DEST_ROOT }debug/js/vendor.js", '<%= uglify.main.dest %>']
        dest: "#{ DEST_ROOT }js/main.js"
    
    clean:
      site: path.resolve DEST_ROOT
      tmpfiles: ["#{ DEST_ROOT }.tmp"]
      debugFiles: ["#{ DEST_ROOT }debug"]
      
    imagemin:
      all:
        options:
          progressive: false
        files: [
          expand: true
          cwd: "#{ SRC_ROOT }img/"
          src: ['**/*.{png,jpg,gif}']
          dest: "#{ DEST_ROOT }img/"
        ]

    svgmin:
      options:
        plugins: [
          removeViewBox: false
        ]
      dist:
        files: [
          expand: true
          cwd: "#{ DEST_ROOT }.tmp/svg/"
          src: ['*.svg']
          dest: "#{ DEST_ROOT }img/"
        ]
    
    shell:
      coffeelint:
        command:
          "#{ BIN }coffeelint #{ JS_ROOT }main/*.coffee"
        options:
          stdout: true
      coffeelint_grunt:
        command:
          "#{ BIN }coffeelint #{ __filename }"
        options:
          stdout: true
    
    connect:
      options:
        livereload: 35729
        port: settings.liveReloadPort
      site:
        options:
          base: DEST_ROOT
    
    open:
      site:
        # stackoverflow.com/questions/1349404/#comment13539914_8084248
        path: "#{ settings.siteURL }?v=#{
          Math.random()
            .toString(36)
            .substr(2, 5)
        }"
        app: 'Google Chrome'
    
    watch:
      options:
        livereload: '<%= connect.options.livereload %>'

      bower:
        files: ["#{ SRC_ROOT }bower.json"]
        tasks: ['bower', 'uglify:bower']
      compass:
        files: ["#{ SRC_ROOT }scss/*.scss"]
        tasks: ['compass', 'postprocessCSS']
      coffee:
        files: ["#{ JS_ROOT }main/*.coffee"]
        tasks: ['shell:coffeelint', 'coffee', 'uglify:main', 'concat:main']
      coffee_grunt:
        files: 'Gruntfile.coffee'
        tasks: ['shell:coffeelint_grunt']
      concat_vendor:
        files: '<%= concat.vendor.src %>'
        tasks: ['concat:vendor', 'concat:main']
      concat_vendor_ie:
        files: '<%= concat.vendor_ie.src %>'
        tasks: ['concat:vendor_ie']
      images:
        files: ["#{ SRC_ROOT }img/**/*.{png,jpg,gif}"]
        tasks: ['imagemin:all']
      svg:
        files: ["#{ SRC_ROOT }img/**/*.svg"]
        tasks: ['flexSVG', 'svgmin']
      jade:
        files: ["#{ SRC_ROOT }jade/**/*.{jade,json,yaml,yml}"]
        tasks: ['jadeTemplate:dev', 'jadeTemplate:dist']
      copy:
        files: ["#{ SRC_ROOT }public/**/*"]
        tasks: ['copy:public']
        
    'gh-pages':
      options:
        base: DEST_ROOT
        branch: 'master'
        message: 'deployed by grunt-gh-pages'
      site:
        src: '**/*'
    
    prompt:
      message:
        options:
          questions: [
            {
              config: 'gh-pages.options.message'
              type: 'input'
              message: 'Enter the commit message.'
              default: 'deployed by grunt-gh-pages'
            }
          ]

    concurrent:
      preparing: [
        'bower', 'shell'
      ]
      dev: ['coffee:dev', 'jadeTemplate:dev']
      dist: [
        'compass'
        'coffee:dist'
        'jadeTemplate:dist'
        'imagemin'
        'flexSVG'
      ]
  
  # Compile .jade files with frontmatter
  grunt.task.registerTask 'jadeTemplate',
  'Compile Jade files with front-matter', (mode) ->
    
    devMode = mode isnt 'dist'

    globalData = {}
    
    grunt.file.recurse "#{ SRC_ROOT }jade/data/",
      (abspath, rootdir, subdir, filename) ->
        _basename = path.basename filename, path.extname(filename)
    
        if path.extname(filename) is '.json'
          globalData[_basename] = grunt.file.readJSON abspath

        if path.extname(filename) is '.yaml' or
        path.extname(filename) is '.yml'
          globalData[_basename] = grunt.file.readYAML abspath
    
    getComponentVersion = (name) ->
      _bowerPath = "#{ SRC_ROOT }bower_components/#{ name }/bower.json"
      return grunt.file.readJSON(_bowerPath).version

    globalData.jquery_ver = getComponentVersion 'jquery'
    globalData.jquery1_ver = getComponentVersion 'jquery1'

    mapOptions =
      cwd: "#{ SRC_ROOT }jade/pages/"
      filter: 'isFile'
      ext: '.html'
      rename: (dest, src) ->
        dest + (if devMode then 'debug/' else '') + src
    
    fileMap = grunt.file.expandMapping '**/*.jade', DEST_ROOT, mapOptions
        
    compileOptions =
      pretty: false
      # HTMLファイルのパスは書き出し先のフォルダのルートが基準となる
      filename: mapOptions.cwd + '../'
    
    for filePath in fileMap
      srcPath = filePath.src[0]
      destPath = filePath.dest
      
      raw = yfm.extract srcPath
      
      localData = raw.context
      
      jadeTxt = """
      extend ../templates/#{ localData.template or localData.layout }
      #{ raw.content }
      """
      
      # helper
      ## ディレクトリ名と拡張子を取り除いたファイル名
      localData.basename = path.basename srcPath, '.jade'

      ## プロジェクトの画像のファイルパス、サイズ
      localData.projectImages = []

      projectImagePaths = grunt.file.expand {
        cwd: SRC_ROOT
      }, "img/projects/#{ localData.basename }/**/*.{png,jpg,gif}"
      
      for imagePath, i in projectImagePaths
        _dimesions = sizeOf imagePath
        
        localData.projectImages[i] =
          path: imagePath
          width: _dimesions.width
          height: _dimesions.height
          
      
      allData = _.assign globalData, localData, compileOptions
      
      if devMode
        allData = _.assign allData, {DEBUG: true, pretty: true}
      
      jade.render jadeTxt, allData, (err, html) ->
        if err
          console.warn err
        else
          grunt.file.write destPath, html
          console.log "File \"#{ destPath }\" created."
      
  # Remove 'width' and 'height' properties from SVG
  grunt.task.registerTask 'flexSVG', 'An internal task.', ->
    _cwd = "#{ SRC_ROOT }img/"
    srcSVGs = grunt.file.expand {cwd: _cwd}, '*.svg'
    srcSVGs.forEach (filepath) ->
      svgString = grunt.file.read _cwd + filepath
      match = svgString.match /width([^)]+)viewBox/
      if match?
        svgString = svgString.replace match, 'viewBox'
      grunt.file.write "#{ DEST_ROOT }.tmp/svg/#{ filepath }", svgString
      
  grunt.task.registerTask 'postprocessCSS', ['autoprefixer', 'cssmin']

  defaultTasks = [
    'clean:site' #reset
    'concurrent:preparing'
    'copy'
    'concurrent:dev', 'concurrent:dist'
    'uglify', 'concat' #minify JS
    'postprocessCSS'
    'svgmin'
    'connect', 'watch'
  ]
  
  grunt.task.registerTask 'default', defaultTasks
  
  # task list for 'dist' tasks
  distTasks = _(defaultTasks)
    .without('concurrent:dev', 'watch')
    .union(['clean:tmpfiles', 'clean:debugFiles', 'addNoJekyll'])
    .valueOf()
  
  grunt.task.registerTask 'dist',
    'Generate only the files to publish a website',
    distTasks
  
  grunt.task.registerTask 'deploy',
    'Deploy to Github Pages',
    ->
      grunt.loadNpmTasks 'grunt-prompt'
      grunt.loadNpmTasks 'grunt-gh-pages'
      grunt.loadNpmTasks 'grunt-open'
      
      ini = require 'ini'
      gitConfig = ini.parse grunt.file.read "#{ HOME_DIR }/.gitconfig"
      
      grunt.config.set 'gh-pages.options.user', gitConfig.user

      grunt.task.run 'dist', 'prompt', 'gh-pages', 'open'
