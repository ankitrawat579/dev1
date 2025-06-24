// LWC JavaScript
import { LightningElement, track, api, wire } from 'lwc';
import getEmployeeLeaves from '@salesforce/apex/GetEmployeeDetails.getEmployeeLeaves';

const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
];

export default class CalendarComponent extends LightningElement {
    @api recordId;
    @track currentDate = new Date();
    @track calendarRows = [];
    @track monthYear = '';
    @track isModalOpen = false;
    @track selectedDate = '';
    @track eventInput = '';
    @track events = {};

    @track leaveDates = new Set();
    @track holidayDates = new Set();
    @track totalHoursMap = new Map();

    connectedCallback() {
        this.loadCalendar();
    }

    @wire(getEmployeeLeaves)
    employeeLeaves({ error, data }) {
        if (data) {
            if (data.lstOfLeave) {
                this.leaveDates = new Set(data.lstOfLeave);
            }
            if (data.lstOfHoliday) {
                this.holidayDates = new Set(data.lstOfHoliday);
            }
            if (data.totalHoursMap) {
                this.totalHoursMap = new Map(Object.entries(data.totalHoursMap));
            }
            this.loadCalendar();
        } else if (error) {
            console.log('Error fetching employee data:', error);
        }
    }

    loadCalendar() {
        const year = this.currentDate.getFullYear();
        const month = this.currentDate.getMonth();
        this.monthYear = `${months[month]} ${year}`;
        const firstDay = new Date(year, month, 1).getDay();
        const numDays = new Date(year, month + 1, 0).getDate();

        let rows = [];
        let day = 1;

        for (let i = 0; i < 6; i++) {
            let row = [];
            for (let j = 0; j < 7; j++) {
                const isWeekend = j === 0 || j === 6;

                if ((i === 0 && j < firstDay) || day > numDays) {
                    row.push({
                        day: null,
                        dateKey: `${year}-${month}-${i}-${j}`,
                        cssClass: isWeekend ? 'weekend' : ''
                    });
                } else {
                    const dateKey = `${year}-${(month + 1).toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`;
                    const isLeave = this.leaveDates.has(dateKey);
                    const isHoliday = this.holidayDates.has(dateKey);
                    //taking total time from map
                    const workingTime = this.totalHoursMap.get(dateKey);

                    const classes = [];
                    if (isLeave) classes.push('leave-day');
                    if (isHoliday) classes.push('holiday-day');

                    //logic for the coloring 

                    // logic for the coloring
                    if (!isLeave && !isHoliday && workingTime) {
                        if (workingTime === 'Absent') {
                            classes.push('Absent');
                        } else {
                            let hours = parseFloat(workingTime);
                            if (!isNaN(hours)) {
                                if (hours < 7) {
                                    classes.push('Half-day');
                                } else if (hours >= 7 && hours <= 9) {
                                    classes.push('present-day');
                                } else if (hours > 9) {
                                    classes.push('present-day'); // Same class for >9 hrs if you want
                                }
                            }
                        }
                    }


                    if (isWeekend) classes.push('weekend');

                    row.push({
                        day,
                        dateKey,
                        event: this.events[dateKey] || '',
                        cssClass: classes.join(' ')
                    });
                    day++;
                }
            }
            rows.push({ id: `row-${i}`, cells: row });
        }
        this.calendarRows = rows;
    }

    handlePrevMonth() {
        this.currentDate.setMonth(this.currentDate.getMonth() - 1);
        this.loadCalendar();
    }

    handleNextMonth() {
        this.currentDate.setMonth(this.currentDate.getMonth() + 1);
        this.loadCalendar();
    }

    handleDateClick(event) {
        const day = event.currentTarget.dataset.day;
        const dateKey = event.currentTarget.dataset.date;

        if (!day || !dateKey) return;

        this.selectedDate = dateKey;
        this.eventInput = this.events[dateKey] || '';
        this.isModalOpen = true;
    }

    handleInputChange(event) {
        this.eventInput = event.target.value;
    }

    saveEvent() {
        if (this.eventInput.trim()) {
            this.events[this.selectedDate] = this.eventInput.trim();
            this.closeModal();
            this.loadCalendar();
        }
    }

    closeModal() {
        this.isModalOpen = false;
        this.eventInput = '';
        this.selectedDate = '';
    }
}