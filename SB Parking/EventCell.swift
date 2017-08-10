import UIKit
import SwiftyJSON


//This is the class that populates the table of bookings with data. 
//The struct below is the various datatags that are used to populate it in "MyBookingsViewController"
struct Event {
    let subject: String
    let start: String
    let end: String
}
//DeleteEvent is supposed to delete the pressed event, but is still not set up yet.
class EventCell: UITableViewCell {
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBAction func DeleteEvent(_ sender: UIButton){

    }
    var subject: String? {
        didSet {
            subjectLabel.text = subject
        }
    }
    var start: String? {
        didSet {
            startLabel.text = start
        }
    }
    var end: String? {
        didSet {
            endLabel.text = end
        }
    }
}

class EventsDataSource: NSObject {
    let events: [Event]
    
    init(events: [JSON]?) {
        var evtArray = [Event]()
        
        if let unwrappedEvents = events {
            for (event) in unwrappedEvents {
                let newEvent = Event(
                    subject: event["subject"].stringValue,
                    start: Formatter.dateTimeTimeZoneToString(date: event["start"]),
                    end: Formatter.dateTimeTimeZoneToString(date: event["end"]))
                
                evtArray.append(newEvent)
                }
        }
        self.events = evtArray
    }
}

extension EventsDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventCell.self)) as! EventCell
        let event = events[indexPath.row]

        cell.subject = event.subject
        cell.start = event.start
        cell.end = event.end
        return cell
    }
}
