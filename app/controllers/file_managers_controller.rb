require 'google/cloud/storage'

class FileManagersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_file_manager, only: %i[show edit update destroy]

  # GET /file_managers or /file_managers.json
  def index
    @file_managers = FileManager.all
  end

  # GET /file_managers/new
  def new
    @file_manager = FileManager.new
  end

  # POST /file_managers or /file_managers.json
  def create
    @file_manager = FileManager.new(file_manager_params)

    respond_to do |format|
      if @file_manager.save
        store_to_storage(@file_manager.file_name, @file_manager.content)
        format.html { redirect_to file_manager_url(@file_manager), notice: 'File manager was successfully created.' }
        format.json { render :show, status: :created, location: @file_manager }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @file_manager.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /file_managers/1 or /file_managers/1.json
  def update
    respond_to do |format|
      if @file_manager.update(file_manager_params)
        format.html { redirect_to file_manager_url(@file_manager), notice: 'File manager was successfully updated.' }
        format.json { render :show, status: :ok, location: @file_manager }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @file_manager.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /file_managers/1 or /file_managers/1.json
  def destroy
    @file_manager.destroy

    respond_to do |format|
      format.html { redirect_to file_managers_url, notice: 'File manager was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def store_to_storage(file_name, body)
    storage = Google::Cloud::Storage.new(project_id: ENV.fetch('GCP_PROJECT_ID', 'zigexn-vn-sandbox'))
    data = StringIO.new body

    bucket = storage.bucket 'gcp_rails_demo'

    bucket.create_file data, file_name
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_file_manager
    @file_manager ||= Rails.cache.fetch("file_id_#{params[:id]}", expires_in: 1.minutes) do
      FileManager.find(params[:id])
    end
  end

  # Only allow a list of trusted parameters through.
  def file_manager_params
    params.require(:file_manager).permit(:file_name, :content)
  end
end
