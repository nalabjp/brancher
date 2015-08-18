require "active_record"

module Brancher
  module DatabaseRenameService
    extend self

    def rename!(configurations)
      configuration = configurations[env]
      database_extname = File.extname(configuration["database"])
      database_name = configuration["database"].gsub(%r{#{database_extname}$}) { "" }
      database_name += suffix unless database_name =~ %r{#{suffix}$}
      configuration["database"] = cap_length(database_name + database_extname)
      configurations
    end

    def suffix
      return nil if current_branch.blank?
      return nil if Brancher.config.except_branches.include?(current_branch)

      "_#{current_branch}"
    end

    private

    def cap_length(database_name)
      database_name = database_name.slice(0,Brancher.config.max_database_name_length-22) + [Digest::MD5.digest(database_name)].pack("m0").slice(0,22) if database_name.length > Brancher.config.max_database_name_length
      database_name
    end

    def env
      Rails.env
    end

    def current_branch
      @current_branch ||= `git rev-parse --abbrev-ref HEAD`.chomp
    end
  end
end
