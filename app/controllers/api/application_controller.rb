# coding: utf-8
class Api::ApplicationController < ApplicationController
  # Don't force org urls
  skip_before_filter :ensure_org_url_if_org_user, :browser_is_html5_compliant?, :verify_authenticity_token
  before_filter :api_authorization_required

  protected

  # This only allows to authenticate if sending an API request to username.api_key subdomain,
  # but doesn't breaks the request if can't authenticate
  def optional_api_authorization
    if params[:api_key].present?
      authenticate(:api_key, :api_authentication, :scope => CartoDB.extract_subdomain(request))
    end
  end

  def set_start_time
    @time_start = Time.now
  end

  # dry up the jsonp output
  def render_jsonp(obj, status = 200, options = {})
    if callback_valid?
      options.reverse_merge! :json => obj, :status => status, :callback => params[:callback]
    else
      options.reverse_merge! :json => { errors: { callback: "Invalid callback format" } }, :status => 400
    end
    render options
  end

  private

  def callback_valid?
    # While only checks basic characters, represents most common use of JS function names
    params[:callback].nil?  || !!(params[:callback] =~ /\A[$a-z_][0-9a-z_$]*\z/i)
  end
end
