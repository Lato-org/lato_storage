module LatoStorage
  class ApplicationController < Lato::ApplicationController
    layout 'lato/application'
    before_action :authenticate_session
    before_action :authenticate_lato_storage_admin
    before_action { active_sidebar(:lato_storage); active_navbar(:lato_storage) }

    def index
    end

    protected

    def authenticate_lato_storage_admin
      return true if @session.user&.lato_storage_admin

      redirect_to lato.root_path, alert: 'You have not access to this section.'
    end
  end
end