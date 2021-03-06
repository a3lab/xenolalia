import java.util.*;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

class ExperimentInfo {

  final String TIME_API_URL = "http://worldtimeapi.org/api/ip";

  String timeZone;
  String shortTimeZone;
  int unixTime;
  String timeSource;
  
  ExperimentInfo() {
    reset();
  }

  // Fetches basic data.
  void reset() {
    try {
      JSONObject data = loadJSONObject(TIME_API_URL);
      timeZone = data.getString("timezone");
      unixTime = data.getInt("unixtime");
      shortTimeZone = data.getString("abbreviation");
      timeSource = "worldtimeapi";
    } catch (Exception e) {
      Calendar cal = Calendar.getInstance();
      timeZone = cal.getTimeZone().getID();
      shortTimeZone = cal.getTimeZone().getDisplayName(false, TimeZone.SHORT);
      unixTime = (int)(cal.getTimeInMillis()/1000);
      timeSource = "local";
    }
  }

  // Returns UID.
  String getUid() {
    Calendar cal = getCalendarInstance(unixTime);
    return timeStamp(cal) + "_" + settings.sessionName() + "_" + settings.nodeName();
  }

  // Returns all information as JSON object.
  JSONObject getInfo() {
    JSONObject data = new JSONObject();

    data.setString("node_name", settings.nodeName());
    data.setString("session_name", settings.sessionName());
    data.setString("uid", getUid());
    data.setString("time_source", timeSource);

    data.setInt("n_feedback_steps", settings.nFeedbackSteps());

    data.setString("time_zone", timeZone);
    data.setString("time_zone_short", shortTimeZone);
    data.setInt("unix_time", unixTime);

    // UTC time.
    Calendar cal = getCalendarInstance(unixTime);
    data.setString("utc_time_stamp", timeStamp(cal));
    data.setJSONObject("utc_time", dateToJSON(cal));

    // Local time.
    cal.setTimeZone(TimeZone.getTimeZone(shortTimeZone));
    data.setJSONObject("local_time", dateToJSON(cal));

    return data;
  }

  // Saves to JSON file.
  void saveInfoFile(String filename) {
    saveJSONObject(getInfo(), filename);
  }

  // Returns UTC timestamp.
  String timeStamp(Calendar cal) {
    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd_HH:mm:ss");
    return formatter.format(cal.getTime());
  }

  // Returns date as JSON object.
  JSONObject dateToJSON(Calendar cal) {
    JSONObject obj = new JSONObject();
    obj.setInt("year", cal.get(Calendar.YEAR));
    obj.setInt("month", cal.get(Calendar.MONTH) + 1);
    obj.setInt("day", cal.get(Calendar.DAY_OF_MONTH));
    obj.setInt("hour", cal.get(Calendar.HOUR_OF_DAY));
    obj.setInt("minute", cal.get(Calendar.MINUTE));
    obj.setInt("second", cal.get(Calendar.SECOND));

    return obj;
  }

  // Returns appropriate calendar instance based on unix time.
  Calendar getCalendarInstance(long ut) {
    Calendar cal = Calendar.getInstance();
    cal.setTimeZone(TimeZone.getTimeZone("UTC"));
    cal.setTimeInMillis((long)ut*1000);
    return cal;
  }

}
