module ZAWS
  module Helper
    class ZFile

      # This prepend function not currently unit tested,
      # see "thor/spec/actions/file_manipulation_spec"
      # for ideas on how to accomplish this.
      def prepend(command, description, filepath)
        new_file=filepath + ".new"
        File.open(new_file, 'w') do |fo|
          fo.puts description
          fo.puts command
          File.foreach(filepath) do |li|
            fo.puts li
          end
        end
        File.rename(new_file, filepath)
      end

    end
  end
end

