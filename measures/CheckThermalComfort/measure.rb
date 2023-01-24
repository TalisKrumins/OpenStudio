class CheckThermalComfort < OpenStudio::Measure::ModelMeasure
    def name
      return "Check Thermal Comfort"
    end
  
    def description
      return "This measure checks if a thermal comfort level within the range of a Predicted Mean Vote (PMV) of -1 to +1 is achieved across not less than 95% of the floor area of all occupied zones for not less than 98% of the annual hours of operation of the building."
    end
  
    def arguments(model)
      args = OpenStudio::Measure::OSArgumentVector.new
      return args
    end
  
    def run(model, runner, user_arguments)
      super(model, runner, user_arguments)
  
      # Get the thermal comfort data for all occupied zones
      thermal_comfort_data = get_thermal_comfort_data(model)
  
      # Initialize variables to track the number of hours and floor area that meet the PMV criteria
      total_hours = 0
      hours_within_pmv = 0
      total_area = 0
      area_within_pmv = 0
  
      # Iterate through each zone's thermal comfort data
      thermal_comfort_data.each do |zone_data|
        total_hours += zone_data[:hours]
        hours_within_pmv += zone_data[:hours_within_pmv]
        total_area += zone_data[:floor_area]
        area_within_pmv += zone_data[:area_within_pmv]
      end
  
      # Calculate the percentage of hours and floor area that meet the PMV criteria
      hours_within_pmv_pct = hours_within_pmv / total_hours
      area_within_pmv_pct = area_within_pmv / total_area
  
      # Check if the criteria are met
      if hours_within_pmv_pct >= 0.98 && area_within_pmv_pct >= 0.95
        runner.registerInfo("The thermal comfort level within the range of PMV -1 to +1 is achieved across not less than 95% of the floor area of all occupied zones for not less than 98% of the annual hours of operation of the building.")
      else
        runner.registerError("The thermal comfort level does not meet the criteria.")
      end
  
      return true
    end
  
    def get_thermal_comfort_data(model)
      thermal_comfort_data = []
      model.getThermalZones.each do |zone|
        zone_data = {}
        zone_data[:name] = zone.name.get
        zone_data[:floor_area] = zone.floorArea
        zone_data[:hours] = 8760
        zone_data[:hours_within_pmv] = 0
        zone_data[:area_within_pmv] = 0
        zone_data[:pmv_scores] = []
        zone_data[:pmv_scores] = calculate_pmv_zone

        # register the measure to be used by the application
      CheckThermalComfort.new.registerWithApplication