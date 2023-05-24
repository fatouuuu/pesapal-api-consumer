class ApplicationController < ActionController::Base
    def index
        render file: 'public/documentation.html'
    end
end
