require "converter/converter"

dir = "#{File.dirname __FILE__}/antlr4ruby"
controller = Java2Ruby::ConversionController.new
controller.add_files "#{dir}/src", "#{dir}/lib", Dir.dir_glob("#{dir}/src", "**/*")
controller.run $process_count
