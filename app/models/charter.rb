class Charter
  def self.tipster_profit_chart(tipster)
    @chart2 = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(
          :text => "Profit on " + I18n.t("tipster.ranking.ranges.#{tipster.current_statistics_range}")
      )
      f.xAxis(
          :categories => tipster.profit_dates_for_chart,
          tickInterval: 5
      )
      f.series(
          :name => 'Profit',
          :yAxis => 0,
          :color => '#AABF46',
          :data => tipster.profit_values_for_chart,
          showInLegend: false
      )
      f.yAxis [
                  :title => {
                      :text => "Profit in Euro",
                      :margin => 20
                  }
              ]
      f.chart({:defaultSeriesType => "line"})
    end
  end
end
