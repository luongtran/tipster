//$(function () {
//    if ($('#profil-chart-container').length != 0) {
//        $('#profil-chart-container').highcharts({
//            title: {
//                text: '',
//                x: -20 //center
//            },
//            xAxis: {
//                type: 'datetime',
//                categories: ['Mar', 'Apr', 'May', 'Jun',
//                    'Jul', 'Aug', 'Sep', ''],
//                tickInterval: 24 * 3600 * 1000
//            },
//            yAxis: {
//                title: {
//                    text: 'Bankroll'
//                },
//                plotLines: [
//                    {
//                        value: 0,
//                        width: 1,
//                        color: '#808080'
//                    }
//                ]
//            },
//            tooltip: {
//                valueSuffix: ' units'
//            },
//            legend: false,
//            series: [
//                {
//                    name: 'Profit',
//                    data: [80, 120, 170, 180, 195, 190, 170, 180, 195, 190, 170, 180, 195, 190]
//                }
//            ],
//            credits: {
//                enabled: false
//            }
//        });
//    }
//});