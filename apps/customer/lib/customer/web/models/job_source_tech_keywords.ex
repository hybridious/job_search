defmodule Customer.Web.JobSourceTechKeywords do
  use Customer.Web, :crud

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def tech_keyword_ids_by(job_source_id) do
    JobSourceTechKeyword.by_tech_keyword_ids(job_source_id)
    |> Repo.all
  end

  def bulk_delete_and_upsert(multi, tech_keyword_ids, job_source_id) do
    delete_if_needed(multi, tech_keyword_ids, job_source_id)
    |> bulk_upsert(tech_keyword_ids, job_source_id)
  end

  defp delete_if_needed(multi, tech_keyword_ids, job_source_id) do
    job_source_tech_keywords = JobSourceTechKeyword.by_job_source_id_except_tech_keyword_ids(tech_keyword_ids, job_source_id)
    Multi.delete_all(multi, :job_source_tech_keyword, job_source_tech_keywords)
  end

  def bulk_upsert(job_tech_keyword_ids, job_source_id) do
    bulk_upsert(Multi.new, job_tech_keyword_ids, job_source_id)
  end

  def bulk_upsert(multi, [], _job_source_id), do: multi

  def bulk_upsert(multi, [current_job_tech_keyword_id | remainings], job_source_id) do
    upsert(multi, %{tech_keyword_id: current_job_tech_keyword_id, job_source_id: job_source_id})
    |> bulk_upsert(remainings, job_source_id)
  end

  defp upsert(multi, %{tech_keyword_id: tech_keyword_id, job_source_id: job_source_id} = params) do
    job_source_tech_keyword = Repo.get_by(JobSourceTechKeyword, tech_keyword_id: tech_keyword_id, job_source_id: job_source_id)
    # NOTE: Thie method may be used for bulk upsert, so uuid is used as name

    if job_source_tech_keyword do
      Multi.update(multi, Ecto.UUID.generate, JobSourceTechKeyword.update(job_source_tech_keyword, params))
    else
      Multi.insert(multi, Ecto.UUID.generate, JobSourceTechKeyword.build(params))
    end
  end

end
