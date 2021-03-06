require 'openssl'

module RESTinPeace
  module Faraday
    class SSLConfigCreator
      class MissingParam < StandardError; end

      def initialize(config, verify = :peer)
        @config = config
        @verify = verify

        raise MissingParam, 'Specify :ca_cert in ssl options' unless @config[:ca_cert]
        raise MissingParam, 'Specify :client_key in ssl options' unless @config[:client_key]
        raise MissingParam, 'Specify :client_cert in ssl options' unless @config[:client_cert]
      end

      def faraday_options
        {
          client_cert: client_cert,
          client_key: client_key,
          ca_file: ca_cert_path,
          verify_mode: verify_mode,
        }
      end

      def client_cert
        OpenSSL::X509::Certificate.new(open_file(client_cert_path))
      end

      def client_cert_path
        path(@config[:client_cert])
      end

      def client_key
        OpenSSL::PKey::RSA.new open_file(client_key_path), @config[:client_key_passphrase]
      end

      def client_key_path
        path(@config[:client_key])
      end

      def ca_cert_path
        path(@config[:ca_cert])
      end

      def verify_mode
        case @verify
        when :peer
          OpenSSL::SSL::VERIFY_PEER
        else
          raise "Unknown verify variant '#{@verify}'"
        end
      end

      private

      def open_file(file)
        File.open(file)
      end

      def path(file)
        File.join(file)
      end
    end
  end
end
