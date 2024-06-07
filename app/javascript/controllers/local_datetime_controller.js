import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    date: { type: Boolean, default: true },
    time: { type: Boolean, default: true },
    style: String,
  };

  connect() {
    if (this.dateInput && !this.displayDate && !this.displayTime) {
      console.warn("datetime configured without displaying");
      return;
    } else if (!this.dateInput) {
      console.warn("datetime not configured");
      return;
    }

    if (this.isRelative) {
      this.element.innerText = this.time_ago_in_words;
    } else {
      this.element.innerText = this.localDateTime;
    }
  }

  get time_ago_in_words() {
    const seconds = Math.floor((new Date() - this.dateInput) / 1000);
    const tense = seconds < 0 ? "from now" : "ago";
    const minutes = Math.abs(Math.floor(seconds / 60));
    const hourInMinutes = 60;
    const dayInMinutes = hourInMinutes * 24;
    const weekInMinutes = dayInMinutes * 7;
    const monthInMinutes = weekInMinutes * 4;
    const yearInMinutes = monthInMinutes * 12;

    if (this.displayTime) {
      if (minutes == 0) {
        return `less than a minute ${tense}`;
      }
      if (minutes == 1) {
        return `a minute ${tense}`;
      }
      if (minutes < hourInMinutes) {
        return `${minutes} minutes ${tense}`;
      }
      if (minutes < hourInMinutes * 2) {
        return `about an hour ${tense}`;
      }
      if (minutes < dayInMinutes) {
        return `${Math.floor(minutes / hourInMinutes)} hours ${tense}`;
      }

      if (!this.displayDate) {
        return `over ${Math.floor(minutes / hourInMinutes)} hours`;
      }
    }

    if (!this.displayDate) {
      return;
    }
    if (minutes < dayInMinutes * 2) {
      return `a day ${tense}`;
    }
    if (minutes < weekInMinutes) {
      return `${Math.floor(minutes / dayInMinutes)} days ${tense}`;
    }
    if (minutes < weekInMinutes * 2) {
      return `a week ${tense}`;
    }
    if (minutes < monthInMinutes) {
      return `${Math.floor(minutes / weekInMinutes)} weeks ${tense}`;
    }
    if (minutes < monthInMinutes * 2) {
      return `a month ${tense}`;
    }
    if (minutes < yearInMinutes) {
      return `${Math.floor(minutes / yearInMinutes)} months ${tense}`;
    }
    if (minutes < yearInMinutes * 2) {
      return `about a year ${tense}`;
    }

    return `over ${Math.floor(minutes / yearInMinutes)} years`;
  }

  get localDateTime() {
    if (this.isTimestamp) {
      let parts = [];
      if (this.displayDate) {
        const dateParts = [
          this.dateInput.getFullYear(),
          this.dateInput.getMonth() + 1,
          this.dateInput.getDate(),
        ].map((p) => String(p).padStart(2, "0"))
         .join("/");

        parts.push(dateParts);
      }
      if (this.displayTime) {
        const timeParts = [
          this.dateInput.getHours(),
          this.dateInput.getMinutes(),
          this.dateInput.getSeconds(),
        ].map((p) => String(p).padStart(2, "0"))
         .join(":");
        parts.push(timeParts);
      }
      return parts.join(" ");
    }

    return this.dateInput.toLocaleString(undefined, this.localeFormatOptions);
  }

  get localeFormatOptions() {
    let options = {};
    if (this.displayDate) {
      Object.assign(options, {
        year: "numeric",
        month: "short",
        day: "numeric",
      });
    }
    if (this.displayTime) {
      Object.assign(options, {
        hour12: true,
        hour: "numeric",
        minute: "2-digit",
      });
    }
    return options;
  }

  get dateInput() {
    return new Date(this.iso8601);
  }

  get iso8601() {
    return this.element.dateTime;
  }

  get style() {
    return this.hasStyleValue && this.styleValue;
  }

  get isRelative() {
    return this.style === "relative";
  }

  get isTimestamp() {
    return this.style === "timestamp";
  }

  get displayDate() {
    return this.hasDateValue && this.dateValue;
  }

  get displayTime() {
    return this.hasTimeValue && this.timeValue;
  }
}