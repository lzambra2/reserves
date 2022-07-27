class Setting < RailsSettings::CachedSettings
  def self.fiscal_date
    d = Date.parse(Setting.reports_fiscal_year_start)

    if d > Date.today
      d - 1.year
    else
      d
    end
  end
end
