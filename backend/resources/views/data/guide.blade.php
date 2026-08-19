<style>
    .card-title {
        font-size: 1.2rem;
    }
</style>

<div class="card">
    <div class="card-body">

        <div class="row">
            <div class="col-md-6 card-title">
                認證通過導遊
            </div>
            <div class="col-md-6" style="text-align: right">
                <?php echo $days; ?>
            </div>
        </div>
    </div>

    <div id="guide" style="height: 400px;background:#ffffff;margin-bottom: 10px;padding: 10px"></div>
</div>

<script>
    $(function () {
        var dates = @json($dates);
        var number = @json($number);

        var chartDom = document.getElementById('guide');
        var myChart = echarts.init(chartDom);
        var option = {
            tooltip: {
                trigger: 'axis'
            },
            grid: {
                left: '3%',
                right: '4%',
                bottom: '3%',
                containLabel: true
            },
            xAxis: {
                type: 'category',
                data: dates
            },
            yAxis: {
                type: 'value'
            },
            series: [
                {
                    name: '認證通過導遊',
                    type: 'line',
                    stack: 'Total',
                    data: number
                }
            ]
        };

        myChart.setOption(option);

        window.addEventListener('resize', function () {
            myChart.resize();
        })

        let days = 7;

        $('.guide').click(function () {
            days = $(this).data().id

            $.ajax({
                url: "/{{ $admin }}/api/getGuideData",
                data: {
                    days: days
                },
                type: 'GET',
                success: function (response) {
                    console.log(response);

                    myChart.setOption({
                        xAxis: {
                            type: 'category',
                            data: response.dates
                        },
                        series: [
                            {
                                name: '認證通過導遊',
                                type: 'line',
                                stack: 'Total',
                                data: response.number
                            }
                        ]
                    })
                },
                error: function (error) {
                }
            });
        });


    });
</script>
