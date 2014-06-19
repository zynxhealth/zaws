module ZAWS
  module Helper
	class File

	  # This prepend function not currently unit tested, 
	  # see "thor/spec/actions/file_manipulation_spec" 
	  # for ideas on how to accomplish this.
	  def self.prepend(command,description,filepath)
        new_file=filepath + ".new"
        IO::File.open(new_file, 'w') do |fo|
          fo.puts description
          fo.puts command
          IO::File.foreach(filepath) do |li|
            fo.puts li
          end
        end
        IO::File.rename(new_file, filepath)
	  end

	end
  end
end

