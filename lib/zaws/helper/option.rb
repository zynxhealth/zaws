module ZAWS
  module Helper
    class Option

      def self.exists?(optarr, opt_hash)
        optarr.all? { |opt| opt_hash[opt] }
      end

      def self.absent(optarr, opt_hash)
        optarr.inject([]) { |missing, opt| opt_hash[opt] ? missing : missing << opt }
      end

      def self.exclusive?(optarr, opt_hash)
        (optarr.inject(0) { |total, opt| opt_hash[opt] ? total + 1 : total }) <= 1
      end

      def self.minimum?(min, optarr, opt_hash)
        (optarr.inject(0) { |total, opt| opt_hash[opt] ? total + 1 : total }) >= min
      end

    end
  end
end
