require "rjava"
require "jre4ruby"

lib_path = "#{File.dirname(__FILE__)}/antlr4ruby/lib"
fix_path = "#{File.dirname(__FILE__)}/antlr4ruby/fix"

add_class_loader { |package_path|
  dirs, names = list_paths "#{lib_path}/#{package_path}"
  
  dirs.each do |dir|
    import_package dir, package_path
  end
  
  names.each do |name|
    file_path = "#{package_path}/#{name}.rb"
    if File.exist?("#{fix_path}/#{file_path}")
      import_class name, "antlr4ruby/lib/#{file_path}", "antlr4ruby/fix/#{file_path}"
    else
      import_class name, "antlr4ruby/lib/#{file_path}"
    end
  end
}
