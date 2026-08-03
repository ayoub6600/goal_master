document.addEventListener("DOMContentLoaded", function () {
  // Handle pagination link clicks
  document.querySelectorAll('.pagination a').forEach(link => {
    link.addEventListener('click', function (e) {
      e.preventDefault(); // Prevent default link behavior
      const Url = this.getAttribute('href');
      const params = new URLSearchParams(window.location.search);

      const branchId = params.get('branch_id');
      const customer_search = params.get('customer_search');
      const customer_id = params.get('customer_id');
      const date = params.get('date');
      const categoryId = params.get('category_id');
      const bookingServiceId = params.get('bookingServiceId');

      let pageUrl = Url; // Start with the base URL

      if (branchId) {
        pageUrl += '?branch_id=' + branchId;
      }

      if (date) {
        pageUrl += (pageUrl.includes('?') ? '&' : '?') + 'date=' + date;
      }

      if (categoryId) {
        pageUrl += (pageUrl.includes('?') ? '&' : '?') + 'category_id=' + categoryId;
      }
      if (customer_search) {
        pageUrl += (pageUrl.includes('?') ? '&' : '?') + 'customer_search=' + customer_search;
      }
      if (customer_id) {
        pageUrl += (pageUrl.includes('?') ? '&' : '?') + 'customer_id=' + customer_id;
      }
      if (bookingServiceId) {
        pageUrl += (pageUrl.includes('?') ? '&' : '?') + 'bookingServiceId=' + bookingServiceId;
      }
      fetchBookings(pageUrl);
    });
  });

  function fetchBookings(url) {
    fetch(url)
      .then(response => response.text())
      .then(html => {
        // Update the table head and body with the new data
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, 'text/html');

        // Replace the existing table content and pagination links
        const newTable = doc.querySelector('.calendar-table').innerHTML;
        const newPaginationLinks = doc.querySelector('.pagination-links').innerHTML;

        // Update the table head and body
        document.querySelector('.calendar-table').innerHTML = newTable;

        // Replace the pagination links
        document.querySelector('.pagination-links').innerHTML = newPaginationLinks;

        // Re-attach event listeners to new pagination links
        document.querySelectorAll('.pagination a').forEach(link => {
          link.addEventListener('click', function (e) {
            e.preventDefault();
            const Url = this.getAttribute('href');
            const params = new URLSearchParams(window.location.search);

            const branchId = params.get('branch_id');
            const customer_search = params.get('customer_search');
            const customer_id = params.get('customer_id');
            const date = params.get('date');
            const categoryId = params.get('category_id');
            const bookingServiceId = params.get('bookingServiceId');

            let pageUrl = Url; // Start with the base URL

            if (branchId) {
              pageUrl += '?branch_id=' + branchId;
            }

            if (date) {
              pageUrl += (pageUrl.includes('?') ? '&' : '?') + 'date=' + date;
            }

            if (categoryId) {
              pageUrl += (pageUrl.includes('?') ? '&' : '?') + 'category_id=' + categoryId;
            }
            if (customer_search) {
              pageUrl += (pageUrl.includes('?') ? '&' : '?') + 'customer_search=' + customer_search;
            }
            if (customer_id) {
              pageUrl += (pageUrl.includes('?') ? '&' : '?') + 'customer_id=' + customer_id;
            }
            if (bookingServiceId) {
              pageUrl += (pageUrl.includes('?') ? '&' : '?') + 'bookingServiceId=' + bookingServiceId;
            }
            fetchBookings(pageUrl);
          });
        });
      })
      .catch(error => console.error('Error fetching bookings:', error));
  }
});

function navigateDate(offset) {
  const dateInput = document.getElementById('date');
  const currentDate = new Date(dateInput.value);

  // Ensure the date is parsed as UTC to avoid timezone issues
  currentDate.setUTCDate(currentDate.getUTCDate() + offset);

  // Format the date back to yyyy-mm-dd format
  const newDate = currentDate.toISOString().split('T')[0];
  dateInput.value = newDate;

  // Submit the form after setting the new date
  dateInput.form.submit();
}

function fetchBookingDetails(serviceId) {

  function updateServiceStatus(data) {
    // Define the mapping of status codes to names within the function
    const statusName = (() => {
      switch (data.data && data.data.status) {
        case 0:
          return 'Pending';
        case 1:
          return 'Processing';
        case 2:
          return 'Approved';
        case 3:
          return 'Cancelled';
        case 4:
          return 'Done';
        default:
          return 'N/A';
      }
    })();
    return statusName;
  }

  // Make an AJAX call to fetch booking details
  fetch(`/get-booking-info-by-service-id?sch_service_booking_id=${serviceId}`)
    .then(response => response.json())
    .then(data => {
      const statusName = updateServiceStatus(data);
      // Populate the modal content with the new structure
      document.getElementById('scheduleEmployeeImage').src = data.data.image_url || ''; // Adjust as needed
      document.getElementById('scheduleServiceId').innerText = data.data.id || 'N/A'; // Adjust according to your data structure
      document.getElementById('scheduleEmployee').innerText = data.data.employee || 'N/A'; // Adjust according to your data structure
      document.getElementById('scheduleSpecialist').innerText = data.data.specialist || 'N/A'; // Adjust as needed
      document.getElementById('scheduleBranch').innerText = data.data.branch || 'N/A';
      document.getElementById('scheduleCustomer').innerText = data.data.customer || 'N/A';
      document.getElementById('scheduleCustomerPhone').innerText = data.data.phone_no || 'N/A';
      // document.getElementById('scheduleCustomerEmail').innerText = data.data.email || 'N/A';
      document.getElementById('scheduleServiceDate').innerText = data.data.date || 'N/A';
      document.getElementById('scheduleService').innerText = data.data.service || 'N/A';
      document.getElementById('scheduleServiceTime').innerText = data.data.start_time || 'N/A';
      document.getElementById('schedulePaidAmount').innerText = data.data.paid_amount || 'N/A';
      document.getElementById('scheduleServiceStatus').innerText = statusName || 'N/A';

      // Show the modal
      const bookingModal = new bootstrap.Modal(document.getElementById('modalViewScheduleDetails'));
      bookingModal.show();
    })
    .catch(error => console.error('Error fetching booking details:', error));
}
function filterCustomers() {
  const input = document.getElementById('customer_search').value.toLowerCase();
  const suggestionsBox = document.getElementById('suggestions');

  // Clear previous suggestions
  suggestionsBox.innerHTML = '';

  // Filter customers based on input
  const filteredCustomers = customers.filter(customer =>
    customer.full_name.toLowerCase().includes(input)
  );

  if (filteredCustomers.length > 0 && input.length > 0) {
    // Show suggestions
    suggestionsBox.style.display = 'block';
    filteredCustomers.forEach(customer => {
      const suggestionItem = document.createElement('div');
      suggestionItem.textContent = customer.full_name + customer.phone_no;
      suggestionItem.classList.add('suggestion-item');
      suggestionItem.onclick = () => selectCustomer(customer.id, customer.full_name);
      suggestionsBox.appendChild(suggestionItem);
    });
  } else {
    suggestionsBox.style.display = 'none'; // Hide suggestions if no match
  }
}

function selectCustomer(id, name) {
  document.getElementById('customer_search').value = name;
  document.getElementById('customer_id').value = id;

  const form = document.querySelector('.filter-form');
  form.submit();
}

function selectAllCustomers() {
  document.getElementById('customer_search').value = '';
  document.getElementById('customer_id').value = '';
  const form = document.querySelector('.filter-form');
  form.submit();
}

$("#btnAddSchedule").on("click", function() {
  $("#cmn_branch_id").val($("#filter_cmn_branch_id").val());
  scheduleTempData = null;
  $("#frmAddScheduleModal").modal('show');
})

// document.getElementById("btnAddSchedule").addEventListener("click", function () {
//   document.getElementById("cmn_branch_id").value = document.getElementById("filter_cmn_branch_id").value;
//   scheduleTempData = null;
//   new bootstrap.Modal(document.getElementById("frmAddScheduleModal")).show();
// });
