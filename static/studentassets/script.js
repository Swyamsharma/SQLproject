const student_id_element = document.getElementById('student_id');
const s_id = student_id_element.textContent.trim();
console.log(s_id);

/*
  Slidemenu
*/
(function() {
	var $body = document.body
	, $menu_trigger = $body.getElementsByClassName('menu-trigger')[0];

	if ( typeof $menu_trigger !== 'undefined' ) {
		$menu_trigger.addEventListener('click', function() {
			$body.className = ( $body.className == 'menu-active' )? '' : 'menu-active';
		});
	}

}).call(this);

// Function to load news content
function loadNews() {
    fetch('/news')
        .then(response => response.json())
        .then(news => {
			console.log(news);
            let newsContent = '<h2 class="text-xl font-bold mb-4">Latest News</h2>';
            news.forEach(item => {
                newsContent += `
                    <div class="bg-white shadow-lg rounded-lg overflow-hidden mb-4">
                        <div class="px-6 py-4">
                            <div class="font-bold text-xl mb-2">${item.title}</div>
                            <p class="text-gray-700 text-base">${item.content}</p>
							<p class="text-sm text-gray-600 gradient-text">${item.posted_date}</p>
                        </div>
                    </div>
                `;
            });
            document.getElementById('ccc').innerHTML = newsContent;
        })
        .catch(error => console.error('Error loading news:', error));
}

// Function to load reports content
function loadReports() {
    fetch('/reports')
        .then(response => response.json())
        .then(reports => {
            let reportsContent = '<h2 class="text-xl font-bold mb-4">Your Reports</h2>';
            reports.forEach(report => {
                reportsContent += `
                    <div class="bg-white shadow-lg rounded-lg overflow-hidden mb-4">
                        <div class="px-6 py-4">
							<div class="font-bold text-xl mb-2">${report.title}</div>
                            <p class="text-gray-700 text-base">${report.content}</p>
                            <p class="text-sm text-gray-600 gradient-text">${report.date}</p>
                        </div>
                    </div>
                `;
            });
            document.getElementById('ccc').innerHTML = reportsContent;
        })
        .catch(error => console.error('Error loading reports:', error));
}

// Function to load complaints content
// Function to load complaints content
function loadComplaints() {
    fetch('/student_complaints')
        .then(response => response.json())
        .then(complaints => {
            let complaintsContent = '<h2 class="text-3xl font-bold mb-4">Your Complaints</h2>';
            complaints.forEach(complaint => {
                let titleColorClass = '';
                switch (complaint.status) {
                    case 'resolved':
                        titleColorClass = 'text-green-600'; // Green color for 'resolved' status
                        break;
                    case 'open':
                        titleColorClass = 'text-red-600'; // Red color for 'open' status
                        break;
                    default:
                        titleColorClass = 'text-yellow-600'; // Default color for other statuses
                        break;
                }
                complaintsContent += `
                    <div class="bg-white shadow-lg rounded-lg overflow-hidden mb-4">
                        <div class="px-6 py-4">
                            <div class="font-bold text-xl mb-2">${complaint.title}</div>
                            <p class="text-gray-700 text-base">${complaint.description}</p>
                            <p class="text-sm text-gray-600">${complaint.complaint_date}</p>
                            <div class="text-sm ${titleColorClass}">${complaint.status}</div>
                            <button class="bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline" onclick="removeComplaint('${complaint.title}')">Remove</button>
                        </div>
                    </div>
                `;
            });
            document.getElementById('ccc').innerHTML = complaintsContent;
        })
        .catch(error => console.error('Error loading complaints:', error));
}

// Function to remove a complaint
function removeComplaint(title) {
    fetch(`/complaints/${title}`, {
        method: 'DELETE'
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Failed to delete complaint');
        }
        return response.json();
    })
    .then(data => {
        console.log('Complaint deleted successfully:', data.message);
        // Reload complaints after deletion
        loadComplaints();
    })
    .catch(error => {
        console.error('Error deleting complaint:', error);
        // Optionally, handle error scenarios here
    });
}

// Function to load student information
function loadStudentInfo() {
    fetch('/student_info')
        .then(response => response.json())
        .then(student => {
			console.log(student);
            const studentInfo = `
                <h2 class="text-2xl font-bold mb-4">Student Information</h2>
                <ul class="divide-y divide-gray-200">
                    <li class="py-2">
                        <span class="font-bold">First Name:</span> ${student.first_name}
                    </li>
                    <li class="py-2">
                        <span class="font-bold">Last Name:</span> ${student.last_name}
                    </li>
                    <li class="py-2">
                        <span class="font-bold">Email:</span> ${student.email}
                    </li>
                    <li class="py-2">
                        <span class="font-bold">Phone:</span> ${student.phone}
                    </li>
                    <li class="py-2">
                        <span class="font-bold">Date of Birth:</span> ${student.date_of_birth}
                    </li>
                    <li class="py-2">
                        <span class="font-bold">Username:</span> ${student.username}
                    </li>
					<li class="py-2">
						<span class="font-bold">Student_id:</span> ${student.student_id}
					</li>
                </ul>
            `;
            document.getElementById('ccc').innerHTML = studentInfo;
        })
        .catch(error => console.error('Error loading student info:', error));
}
// Function to load register complaint form
function loadRegisterForm() {
    const formContent = `
    <h2 class="text-2xl font-bold mb-4">Register Complaint</h2>
    <form id="complaintForm">
        <div class="mb-4">
            <label class="block text-gray-700 text-sm font-bold mb-2" for="complaintTitle">Complaint Title</label>
            <input class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline" id="complaintTitle" type="text" placeholder="Enter complaint title, short and concise" required>
        </div>
        <div class="mb-6">
            <label class="block text-gray-700 text-sm font-bold mb-2" for="complaintDescription">Complaint Description</label>
            <textarea class="resize-y shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline" id="complaintDescription" placeholder="25-150 words, spamming will cause denial from this service" style="min-height: 100px;" required></textarea>
        </div>
        <div class="flex items-center justify-between">
            <button class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline" type="button" onclick="registerComplaint()">Submit</button>
        </div>
    </form>
    `;

    // Display the form in the designated element
    document.getElementById('ccc').innerHTML = formContent;
}
// Function to register a complaint
function registerComplaint() {
	const complaintTitle = document.getElementById('complaintTitle').value;
	const complaintDescription = document.getElementById('complaintDescription').value;
    if (complaintTitle.length < 5 || complaintTitle.length > 100) {
        alert('Complaint title must be between 5 and 100 characters');
        return;
    }
	if (complaintDescription.split(' ').length < 25 || complaintDescription.split(' ').length > 150) {
		alert('Complaint description must be between 25 and 150 words');
		return;
	}
	//cleaning the form
	document.getElementById('complaintTitle').value = '';
	document.getElementById('complaintDescription').value = '';
	//desciption more than 50 words and less than 150
	
    const complaintData = {
		student_id: s_id,
        complaint_title: complaintTitle,
        complaint_description: complaintDescription
    };

    fetch('/complaints', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(complaintData)
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Failed to register complaint');
        }
        return response.json();
    })
    .then(data => {
        console.log('Complaint registered successfully:', data.message);
        // Optionally, you can perform additional actions after successful complaint registration
    })
    .catch(error => {
        console.error('Error registering complaint:', error);
        // Optionally, handle error scenarios here
    });
}

function loadOpenAttendances() {
    fetch('/open_attendances')
        .then(response => response.json())
        .then(data => {
            if (data.length === 0) {
                document.getElementById('ccc').innerHTML = '<p>No open attendances available.</p>';
                return;
            }
            
            let openAttendancesContent = '';
            data.forEach(attendance => {
                openAttendancesContent += `
                    <div class="bg-white shadow-lg rounded-lg overflow-hidden mb-4">
                        <div class="px-6 py-4">
                            <div class="font-bold text-xl mb-2">${attendance.subject}</div>
                            <p class="text-gray-700 text-base">Date: ${attendance.attendance_date}</p>
                            <p class="text-gray-700 text-base">Time: ${attendance.start_time} - ${attendance.end_time}</p>
                            <div class="flex justify-end">
                                <button id="presentBtn_${attendance.attendance_id}" class="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded mr-2" onclick="markAttendance('present', ${attendance.attendance_id})">Present</button>
                            </div>
                        </div>
                    </div>
                `;
            });
            document.getElementById('ccc').innerHTML = openAttendancesContent;
        })
        .catch(error => console.error('Error loading open attendances:', error));
}


function markAttendance(attendanceStatus, attendanceId) {
    const secretCode = prompt(`Please enter the unique code to mark attendance as ${attendanceStatus}:`);
    if (secretCode === null) {
        console.log('Operation cancelled by user');
        return;
    }

    fetch(`/mark_attendance/${attendanceId}/${secretCode}/${attendanceStatus}`, {
        method: 'POST'
    })
    .then(response => {
        if (response.ok) {
            if (attendanceStatus === 'present') {
                console.log('Attendance marked as present');
            } else {
                console.log('Attendance marked as absent');
            }
            // Reload the open attendances after marking attendance
            loadOpenAttendances();
        } else {
            console.error('Error marking attendance');
        }
    })
    .catch(error => console.error('Error marking attendance:', error));
}

document.querySelector('.news').addEventListener('click', function(event) {
    event.preventDefault();
    loadNews();
    document.body.classList.remove('menu-active'); // Close the menu
});

document.querySelector('.reports').addEventListener('click', function(event) {
    event.preventDefault();
    loadReports();
    document.body.classList.remove('menu-active'); // Close the menu
});

document.querySelector('.complaints').addEventListener('click', function(event) {
    event.preventDefault();
    loadComplaints();
    document.body.classList.remove('menu-active'); // Close the menu
});

document.querySelector('.studentinfo').addEventListener('click', function(event) {
    event.preventDefault();
    loadStudentInfo();
    document.body.classList.remove('menu-active'); // Close the menu
});

document.querySelector('.registercomplaint').addEventListener('click', function(event) {
    event.preventDefault();
    loadRegisterForm();
    document.body.classList.remove('menu-active'); // Close the menu
});

document.querySelector('.openattendances').addEventListener('click', function(event) {
    event.preventDefault();
    loadOpenAttendances();
    document.body.classList.remove('menu-active'); // Close the menu
});
