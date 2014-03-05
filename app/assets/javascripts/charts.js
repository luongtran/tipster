/*
 = require highcharts
 */
$(function () {
    if ($('#profil-chart-container').length != 0) {
        $('#profil-chart-container').highcharts({
            title: {
                text: '',
                x: -20 //center
            },
            xAxis: {
                categories: ['Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug']
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
                    data: [80, 120, 170, 180, 195, 190]
                }
            ],
            credits: {
                enabled: false
            }
        });
    }
});