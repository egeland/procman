require 'mixlib/cli'

module Procman
  # Procman::Commandline
  class Commandline
    include Mixlib::CLI

    MISSING_ACTION    = 'Missing or invalid action.'
    MISSING_ARGUMENTS = 'Missing required arguments.'
    MISSING_PROCFILE  = 'Missing procfile argument.'
    INVALID_PROCFILE  = 'Invalid procfile.'

    # rubocop:disable Metrics/LineLength

    option :procfile,
           short:       '-f PROCFILE',
           long:        '--file PROCFILE',
           description: 'Specify an alternate Procfile to load.'

    option :app,
           short:       '-a APP',
           long:        '--app APP',
           description: 'Name of the application. (default: directory name)'

    option :user,
           short:       '-u USER',
           long:        '--user USER',
           description: 'Specify the user the application should be run as. (default: www-data)',
           default:     'www-data'

    option :root,
           short:       '-r ROOT',
           long:        '--root ROOT',
           description: 'Specify an alternate application root. (default: Procfile directory)'

    option :port,
           short:       '-p PORT',
           long:        '--port PORT',
           description: 'Port to use as the base for this application. (default: 5000)'

    option :template,
           short:       '-t TEMPLATE',
           long:        '--template TEMPLATES',
           description: 'Specify an alternate template to use for creating export files. (default: upstart_rvm)',
           default:     'upstart_rvm'

    # rubocop:enable Metrics/LineLength

    def run
      parse
    end

    private

    def parse
      cli     = Procman::Commandline.new
      procman = Procman::App.new(cli.config)

      cli.parse_options

      case (action = action cli.cli_arguments)
      when 'help'
        procman.help(cli)
      when 'version'
        procman.version
      when 'export'
        procman.export if validate(action, cli.config)
      else
        fail(ArgumentError, MISSING_ACTION)
      end
    rescue ArgumentError,
           OptionParser::MissingArgument,
           OptionParser::InvalidOption => e
      puts procman.help(cli)
      puts "ERROR: #{e.message}"
    end

    def action(array)
      array.select { |i| %w(help version export).include? i }.first
    end

    def validate(action, config)
      send(action, config) ? true : fail(ArgumentError, MISSING_ARGUMENTS)
    end

    def export(config)
      procfile = File.file? config[:procfile]
      procfile ? true :  fail(ArgumentError, INVALID_PROCFILE)
    rescue TypeError
      raise(ArgumentError, MISSING_PROCFILE)
    end
  end
end
