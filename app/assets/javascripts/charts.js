$(function () {
    if ($('#profil-chart-container').length != 0) {
        $('#profil-chart-container').highcharts({
            title: {
                text: '',
                x: -20 //center
            },
            xAxis: {
                type: 'datetime',
                categories: ['Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', ''],
                tickInterval: 24 * 3600 * 1000
            },
            yAxis: {
                title: {
                    text: 'Bankroll'
                },
                plotLines: [
                    {
                        value: 0,
                        width: 1,
                        color: '#808080'
                    }
                ]
            },
            tooltip: {
                valueSuffix: ' units'
            },
            legend: false,
            series: [
                {
                    name: 'Profit',
                    data: [80, 120, 170, 180, 195, 190, 170, 180, 195, 190, 170, 180, 195, 190]
                }
            ],
            credits: {
                enabled: false
            }
        });
    }
    if ($('#profil-chart-statistic').length != 0){
        $('#profil-chart-statistic').highcharts({
            chart: {
                plotBackgroundColor: null,
                plotBorderWidth: null,
                plotShadow: false
            },
            title: {
                text: 'Browser market shares at a specific website, 2010'
            },
            tooltip: {
                pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
            },
            plotOptions: {
                pie: {
                    allowPointSelect: true,
                    cursor: 'pointer',
                    dataLabels: {
                        enabled: true,
                        color: '#000000',
                        connectorColor: '#000000',
                        format: '<b>{point.name}</b>: {point.percentage:.1f} %'
                    }
                }
            },
            series: [{
                type: 'pie',
                name: 'Browser share',
                data: [
                    ['Firefox',   45.0],
                    ['IE',       26.8],
                    {
                        name: 'Chrome',
                        y: 12.8,
                        sliced: true,
                        selected: true
                    },
                    ['Safari',    8.5],
                    ['Opera',     6.2],
                    ['Others',   0.7]
                ]
            }]
        });
    }
    if($('#profil-chart-statistic-profit').length != 0){
        $('#profil-chart-statistic-profit').highcharts({
            chart: {
                type: 'areaspline'
            },
            title: {
                text: 'Average fruit consumption during one week'
            },
            legend: {
                layout: 'vertical',
                align: 'left',
                verticalAlign: 'top',
                x: 150,
                y: 100,
                floating: true,
                borderWidth: 1,
                backgroundColor: '#FFFFFF'
            },
            xAxis: {
                categories: [
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday',
                    'Sunday'
                ],
                plotBands: [{ // visualize the weekend
                    from: 4.5,
                    to: 6.5,
                    color: 'rgba(68, 170, 213, .2)'
                }]
            },
            yAxis: {
                title: {
                    text: 'Fruit units'
                }
            },
            tooltip: {
                shared: true,
                valueSuffix: ' units'
            },
            credits: {
                enabled: false
            },
            plotOptions: {
                areaspline: {
                    fillOpacity: 0.5
                }
            },
            series: [{
                name: 'John',
                data: [3, 4, 3, 5, 4, 10, 12]
            }, {
                name: 'Jane',
                data: [1, 3, 4, 3, 3, 5, 4]
            }]
        })
    }
});