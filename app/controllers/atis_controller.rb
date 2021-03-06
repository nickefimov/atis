class AtisController < ApplicationController

  def home

    @token = Token.where(token: params[:token]).first if params[:token].present?
    @token ||= Token.new

  end

  def decode

    @message = ATIS::Message.new(params[:metar]||params[:icao], metar_options_from_params)

    respond_to do |format|
      format.html
      format.text
    end
  end

  def metar

  end

  private

  def metar_options_from_params
    @token = Token.where(token: params[:token]).first if params[:token].present?

    options = ((@token && @token.params) || {}).with_indifferent_access
    options[:lang] = [@token.params[:pl], @token.params[:sl]].reject { |l| l.blank? } if @token.present?
    options.merge! token_options_to_arrays if @token.present?
    options.merge! params_split_to_arrays

    {
        arrival_runways: options[:arr],
        approach_types: options[:apptype],
        departure_runways: options[:dep],
        index: options[:info].try(:downcase),
        transition_level: options[:trlvl],
        extra: options[:extra],
        report_pressure_in: options[:pt],
        languages: options[:lang],
        closed_runways: options[:c_rwys],
        closed_taxiways: options[:c_twys]
    }
  end

  def params_split_to_arrays
    [:arr, :apptype, :dep, :extra, :pt, :lang, :c_rwys, :c_twys].each do |key|
      params[key] = params[key].split(",").map(&:strip) if params[key].is_a?(String)
    end
    params
  end

  def token_options_to_arrays
    {
        c_rwys: @token.params[:c_rwys].to_s.split(",").map(&:strip),
        c_twys: @token.params[:c_twys].to_s.split(",").map(&:strip)
    }
  end

end
