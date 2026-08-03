var Dashboard;
function doneService(id, status) {
	Dashboard.ChangeBookingStatus(id, status);
}

function cancelService(id, status) {
	Dashboard.ChangeBookingStatus(id, status);
}
(function ($) {
    "use strict";	

	$(document).ready(function () {
		$("input[name='booking-info-duration-radio']").hide();
		Dashboard.Common();
		Dashboard.BookingInfo('', 1);
		Dashboard.LoadBranchDropDown();


		
		
		$('#timePeriod').on('change', function () {
			if ($(this).val() === 'custom') {
				$('#customDateRange').removeClass('d-none');
				$('#customDateRange').addClass('d-flex');
			} else {
				$('#customDateRange').addClass('d-none');
				$('#customDateRange').removeClass('d-flex');

				$('#div-body-top-booking-service').empty();
				Dashboard.Common(); // Trigger dashboard refresh for non-custom selections
			}
		});
		
		$('#startDate, #endDate').on('change', function () {
			if ($('#timePeriod').val() === 'custom') {
				$('#div-body-top-booking-service').empty();
				Dashboard.Common(); // Trigger dashboard refresh for custom date range selection
			}
		});


		$('#cmn_branch_id').on('change', function () {
			$('#div-body-top-booking-service').empty();
			Dashboard.Common(); // Trigger dashboard refresh for custom date range selection
		});
		
		$('#exportPdf').on('click', function () {
			// Show the modal asking user to choose export option
			$('#exportModal').modal('show');
		});
		
		// When confirm button in the modal is clicked
		$('#confirmExport').on('click', function () {
			// Get the selected time period and dates
			const timePeriod = $('#timePeriod').val();
			let startDate, endDate;
			const exportOption = $("input[name='exportOption']:checked").val(); // 0 for all, 2 for selected
		
			var branchID =  $('#cmn_branch_id').val();
		
			if (timePeriod === 'custom') {
				startDate = $('#startDate').val();
				endDate = $('#endDate').val();
			} else if (timePeriod === 'day') {
				let now = new Date();
				startDate = endDate = new Date(now.getTime() - (new Date().getTimezoneOffset() * 60000)).toISOString().slice(0, 10);
			} else if (timePeriod === 'week') {
				let now = new Date();
				startDate = new Date(now.setDate(now.getDate() - now.getDay())).toISOString().slice(0, 10);
				endDate = new Date().toISOString().slice(0, 10);
			} else if (timePeriod === 'month') {
				let now = new Date();
				startDate = new Date(now.getFullYear(), now.getMonth(), 1).toISOString().slice(0, 10);
				endDate = new Date().toISOString().slice(0, 10);
			}
		
			// Set up the URL for the export route with query parameters
			const exportUrl = `export-booking-status?start_date=${startDate}&end_date=${endDate}&branchID=${branchID}&exportOption=${exportOption}`;
			window.location.href = exportUrl; // Redirect to the generated URL
		
			// Close the modal after export option is confirmed
			$('#exportModal').modal('hide');
		});
		
		
		
		
		$("#booking-info-duration-pill-today").on("click",function () {
			$("#booking-info-duration-radio-today").prop("checked", true);
			Dashboard.BookingInfo($("#booking-info-service-status").val(), 1);
		});
		$("#booking-info-duration-pill-month").on("click",function () {
			$("#booking-info-duration-radio-monthly").prop("checked", true);
			Dashboard.BookingInfo($("#booking-info-service-status").val(), 2);
		});
		$("#booking-info-service-status").change(function () {
			Dashboard.BookingInfo($(this).val(), $("input[name='booking-info-duration-radio']:checked").val());
		});
		
	
		
		
	});

	Dashboard = {
		Common: function () {
			var jsonParam = '';
			var serviceUrl = "get-dashboard-common-data";
			JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);
			
			var branchID =  $('#cmn_branch_id').val();
			
			var timePeriod = $('#timePeriod').val();

			var startDate, endDate;
	
			// Determine date range based on selected time period
			if (timePeriod === 'day') {
				// startDate = endDate = new Date().toISOString().slice(0, 10);
				startDate = endDate = new Date(new Date().getTime() - (new Date().getTimezoneOffset() * 60000)).toISOString().slice(0, 10);
			} else if (timePeriod === 'week') {
				let now = new Date();
				startDate = new Date(now.setDate(now.getDate() - now.getDay())).toISOString().slice(0, 10);
				endDate = new Date().toISOString().slice(0, 10); // Today
			} else if (timePeriod === 'month') {
				let now = new Date();
				startDate = new Date(now.getFullYear(), now.getMonth(), 1).toISOString().slice(0, 10); // First of the month
				endDate = new Date().toISOString().slice(0, 10); // Today
			} else if (timePeriod === 'custom') {
				startDate = $('#startDate').val();
				endDate = $('#endDate').val();
			}
	
			var jsonParam = { start_date: startDate, end_date: endDate , branchID:branchID};
			var serviceUrl = "get-dashboard-common-data";
			JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

			
			
			function onSuccess(jsonData) {
				if (jsonData.status == 1) {

					//Total Income And Other Statistics
					Dashboard.TotalIncomeAndOtherStatistics(jsonData.data.incomAndOtherStatistics);

					// top services
					Dashboard.TopBookingService(jsonData.data.topService);

					//total service
					var dataTotalBooking = jsonData.data.bookingStatus.totalBooking;
					let totalBooking = dataTotalBooking.reduce((n, { serviceCount }) => n +parseInt(serviceCount), 0);

					//total done booking
					let totalDone = dataTotalBooking.find(f => f.status == 4)?.serviceCount ?? 0;
					let donePer = parseInt((totalDone / totalBooking) * 100);
					Circles.create({
						id: 'divDoneBooking',
						radius: 30,
						value: donePer,
						maxValue: 100,
						width: 7,
						text: donePer??0 + " %",
						colors: ['#f1f1f1', '#28a745'],
						duration: 400,
						wrpClass: 'circles-wrp',
						textClass: 'circles-text',
						styleWrapper: true,
						styleText: true
					});
					$("#divDoneBookingText").text(totalDone);

					//total cancel booking
					let totalCancel = dataTotalBooking.find(f => f.status == 3)?.serviceCount ?? 0;
					let cancelPer = parseInt((totalCancel / totalBooking) * 100);
					Circles.create({
						id: 'divCancelBooking',
						radius: 30,
						value: cancelPer,
						maxValue: 100,
						width: 7,
						text: cancelPer??0 + " %",
						colors: ['#f1f1f1', '#fe3145'],
						duration: 400,
						wrpClass: 'circles-wrp',
						textClass: 'circles-text',
						styleWrapper: true,
						styleText: true
					});
					$("#divCancelBookingText").text(totalCancel);

					//total approved booking
					let totalApproved = dataTotalBooking.find(f => f.status == 2)?.serviceCount ?? 0;
					let approvedPer = parseInt((totalApproved / totalBooking) * 100);
					Circles.create({
						id: 'divApprovedBooking',
						radius: 30,
						value: approvedPer,
						maxValue: 100,
						width: 7,
						text: approvedPer??0 + " %",
						colors: ['#f1f1f1', '#2674da'],
						duration: 400,
						wrpClass: 'circles-wrp',
						textClass: 'circles-text',
						styleWrapper: true,
						styleText: true
					});
					$("#divApprovedBookingText").text(totalApproved);

					//total processing * pending booking
					let totalProcessing = dataTotalBooking.find(f => f.status == 1)?.serviceCount ?? 0;
					let totalPending = dataTotalBooking.find(f => f.status == 0)?.serviceCount??0;
					let processingPendingPer = parseInt(((parseInt(totalProcessing) + parseInt(totalPending)) / parseInt(totalBooking)) * 100);
					Circles.create({
						id: 'divProcessingAndPendingBooking',
						radius: 30,
						value: processingPendingPer,
						maxValue: 100,
						width: 7,
						text: processingPendingPer??0 + " %",
						colors: ['#f1f1f1', '#ffad46'],
						duration: 400,
						wrpClass: 'circles-wrp',
						textClass: 'circles-text',
						styleWrapper: true,
						styleText: true
					});
					$("#divProcessingAndPendingBookingText").text(parseInt(totalProcessing) + parseInt(totalPending));





					//todays service
					var dataTodayBooking = jsonData.data.bookingStatus.todayBooking;
					let totalBookingToday = dataTodayBooking.reduce((n, { serviceCount }) => n + parseInt(serviceCount), 0);

					Circles.create({
						id: 'divTotalBookingToday',
						radius: 35,
						value: totalBookingToday,
						maxValue: totalBookingToday,
						width: 7,
						text: totalBookingToday,
						colors: ['#f1f1f1', '#000'],
						duration: 400,
						wrpClass: 'circles-wrp',
						textClass: 'circles-text',
						styleWrapper: true,
						styleText: true
					});

					Circles.create({
						id: 'divDoneBookingToday',
						radius: 35,
						value: dataTodayBooking.find(f => f.status == 4)?.serviceCount,
						maxValue: totalBookingToday,
						width: 7,
						text: dataTodayBooking.find(f => f.status == 4)?.serviceCount,
						colors: ['#f1f1f1', '#28a745'],
						duration: 400,
						wrpClass: 'circles-wrp',
						textClass: 'circles-text',
						styleWrapper: true,
						styleText: true
					});

					Circles.create({
						id: 'divCancelBookingToday',
						radius: 35,
						value: dataTodayBooking.find(f => f.status == 3)?.serviceCount,
						maxValue: totalBookingToday,
						width: 7,
						text: dataTodayBooking.find(f => f.status == 3)?.serviceCount,
						colors: ['#f1f1f1', '#fe3145'],
						duration: 400,
						wrpClass: 'circles-wrp',
						textClass: 'circles-text',
						styleWrapper: true,
						styleText: true
					});

					Circles.create({
						id: 'divApprovedBookingToday',
						radius: 35,
						value: dataTodayBooking.find(f => f.status == 2)?.serviceCount,
						maxValue: totalBookingToday,
						width: 7,
						text: dataTodayBooking.find(f => f.status == 2)?.serviceCount,
						colors: ['#f1f1f1', '#2674da'],
						duration: 400,
						wrpClass: 'circles-wrp',
						textClass: 'circles-text',
						styleWrapper: true,
						styleText: true
					});

					Circles.create({
						id: 'divProcessingBookingToday',
						radius: 35,
						value: dataTodayBooking.find(f => f.status == 1)?.serviceCount,
						maxValue: totalBookingToday,
						width: 7,
						text: dataTodayBooking.find(f => f.status == 1)?.serviceCount,
						colors: ['#f1f1f1', '#17a2b8'],
						duration: 400,
						wrpClass: 'circles-wrp',
						textClass: 'circles-text',
						styleWrapper: true,
						styleText: true
					});

					Circles.create({
						id: 'divPendingBookingToday',
						radius: 35,
						value: dataTodayBooking.find(f => f.status == 0)?.serviceCount,
						maxValue: totalBookingToday,
						width: 7,
						text: dataTodayBooking.find(f => f.status == 0)?.serviceCount,
						colors: ['#f1f1f1', '#ffad46'],
						duration: 400,
						wrpClass: 'circles-wrp',
						textClass: 'circles-text',
						styleWrapper: true,
						styleText: true
						});

						let dailyTotals = jsonData.data.totalForgevin.dailyTotal ?? 0;
						let totals = jsonData.data.totalForgevin.total ?? 0;
						console.log(dailyTotals , totals);
						
						let dailyTotalPercentage = (dailyTotals / totals) * 100;
						let totalPercentage = (totals / totals) * 100; 
						
						$("#divForgivingGenerousText").text(dailyTotals);
						$("#divTotalForgivingGenerousText").text(totals);
						
						Circles.create({
							id: 'divForgivingGenerousCircle',
							radius: 35,
							value: dailyTotalPercentage,
							maxValue: 100, 
							width: 7,
							text: Math.round(dailyTotalPercentage) + "%", 
							colors: ['#f1f1f1', '#28a745'],
							duration: 400,
							wrpClass: 'circles-wrp',
							textClass: 'circles-text',
							styleWrapper: true,
							styleText: true
						});
						
						Circles.create({
							id: 'divTotalForgivingGenerousCircle',
							radius: 35,
							value: totalPercentage,  
							maxValue: 100,     
							width: 7,
							text: Math.round(totalPercentage) + "%", 
							colors: ['#f1f1f1', '#2674da'],
							duration: 400,
							wrpClass: 'circles-wrp',
							textClass: 'circles-text',
							styleWrapper: true,
							styleText: true
						});
						
				}
			}

			function onFailed(xhr, status, err) {
				Message.Exception(xhr);
			}
		},

		TopBookingService: function (data) {
			$.each(data, function (i, v) {
				var html = '<div class="d-flex">' +
					'<div class="avatar avatar-online">' +
					'<span class="avatar-title rounded-circle border border-white bg-primary text-uppercase">' + v.title.slice(0, 1) + '</span>'
					+
					'</div>' +
					'<div class="flex-1 pt-1 ml-2">' +
					'<h6 class="fw-bold mb-1">' + v.title + '</h6>' +
					'<small class="text-muted">Our top services</small>' +
					'</div>' +
					'<div class="d-flex ml-auto align-items-center">' +
					'<h3 class="text-info fw-bold">' + v.service_count + '</h3>' +
					'</div>' +
					'</div>' +
					'<div class="separator-dashed"></div>';
				$("#div-body-top-booking-service").append(html);
			});
		},
		BookingInfo: function (serviceStatus, duration) {
			JsManager.StartProcessBar()
			var jsonParam = { serviceStatus: serviceStatus, duration: duration };
			var serviceUrl = "get-dashboard-booking-info";
			JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);
			function onSuccess(jsonData) {
				$("#div-body-booking-info").empty();
				if (jsonData.status == 1) {
					var data = jsonData.data;
					$.each(data, function (i, v) {
						var html = '<div class="row">' +
							'<div class="col-md-8">' +
							'<div class="d-flex">' +
							'<div class="float-left avatar avatar-online">' +
							'<span class="avatar-title rounded-circle border border-white bg-info text-uppercase">' + v.customer.slice(0, 1) + '</span>' +
							'</div>' +
							'<div class="float-left ml-3 pt-1">' +
							'<h6 class="text-uppercase fw-bold mb-1">' +
							v.service +
							'<span class=" float-right ' + Dashboard.ServiceFontColorClass(v.status) + ' pl-3">' + Dashboard.ServiceStatus(v.status) + '</span>' +
							'</h6>' +
							'<span class="text-muted">' +
							"No# " + v.id + " | " + v.branch + " | " + v.employee + " | " + "Due# <span class='text-danger'>" + parseFloat(v.due).toFixed(2) + "</span><br/>" +
							v.customer + " | " + v.customer_phone_no + " | " + (v.remarks == null ? "No remarks found!" : v.remarks)
							+ '</span>' +
							'</div>' +
							'</div>' +
							'</div>' +
							'<div class="col-md-4">' +
							'<div class="float-right pt-1">' +
							'<small class="text-muted">' + moment(v.date + ' ' + v.start_time).format('LLL') + '</small>' +
							'<div class="">' +
							'<button ' + (v.status == 4 ? "disabled" : "") + ' onclick="doneService(' + v.id + ',4)" type="button" class="btn btn-sm  btn-success ml-1 float-right"><i class="fas fa-check-circle"></i> خالص</button>' +
							'<button ' + (v.status == 4 ? "disabled" : "") + ' onclick="cancelService(' + v.id + ',3)" type="button" class="btn btn-sm  btn-danger float-right"><i class="fas fa-times-circle"></i> إلغاء</button>' +
							'</div>' +
							'</div>' +
							'</div>' +
							'</div>' +
							'<div class="separator-dashed"></div>';
						$("#div-body-booking-info").append(html);
					});

				}
				JsManager.EndProcessBar()
			}

			function onFailed(xhr, status, err) {
				JsManager.EndProcessBar()
				Message.Exception(xhr);
			}
		},
		ServiceStatus: function (status) {
            var serviceStatus = ['غير خالص', 'بانتظار قبول الطلب', 'موافق عليه', 'إلغاء', 'خالص'];
			// var serviceStatus = ['Pending', 'Processing', 'Approved', 'Cancel', 'Done'];
			return serviceStatus[status];
		},
		ServiceFontColorClass: function (status) {
			var serviceColor = ['fc_pending', 'fc_processing', 'fc_approved', 'fc_cancel', 'fc_done'];
			return serviceColor[status];
		},
		TotalIncomeAndOtherStatistics: function (data) {
			$("#totalIncome").text(parseFloat(data.todayPaidAndDue.reduce((n, { service_amount }) => n + parseFloat(service_amount), 0)).toFixed(2))
			let partialDue = data.todayPaidAndDue.find(f => f.payment_status == 3);
			partialDue = (parseFloat(partialDue?.service_amount ?? 0) - parseFloat(partialDue?.paid_amount ?? 0));
			$("#totalDue").text(parseFloat(data.todayPaidAndDue.find(f => f.payment_status == 2 && f.status == 0)?.service_amount ?? 0 + partialDue).toFixed(2))

			$("#totalCash").text(parseFloat(data.todayPaidBy.find(f => f.type == 1)?.paid_amount ?? 0).toFixed(2))
			$("#totalOnlinePayment").text(parseFloat(data.todayPaidBy.find(f => f.type == 4)?.paid_amount ?? 0).toFixed(2))
			$("#totalAllowedAmountToday").text(parseFloat(data.totalAllowedAmountToday ?? 0).toFixed(2));
		},

		ChangeBookingStatus: function (id, status) {
			if (Message.Prompt()) {
				JsManager.StartProcessBar();
				var jsonParam = { id: id, status: status };
				var serviceUrl = "dashboard.change.booking.status";
				JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

				function onSuccess(jsonData) {
					if (jsonData.status == "1") {
						Message.Success("save");
						Dashboard.BookingInfo($("#booking-info-service-status").val(), $("input[name='booking-info-duration-radio']:checked").val());

					} else {
						Message.Error("sace");
					}
					JsManager.EndProcessBar();
				}

				function onFailed(xhr, status, err) {
					JsManager.EndProcessBar();
					Message.Exception(xhr);
				}
			}
		},

		
        LoadBranchDropDown: function () {
            var jsonParam = '';
            var serviceUrl = "get-branch-dropdown";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                JsManager.PopulateCombo("#cmn_branch_id", jsonData.data, "اختر ادارة", '');
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },



	};
})(jQuery);