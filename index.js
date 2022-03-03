const express = require('express');
const bodyParser = require('body-parser');
const app = express();

const holidays = [
  {month: 'January', holidays: 'January 1st - New Years Day'},
  {month: 'February', holidays: 'Black History Month, February 2nd - Groundhog Day, February 14th - Valentines Day, February 15th - Flag Day'},
  {month: 'March', holidays: 'Canada Music Week, March 8th - Internation Womens Day, March 14th - Commonwealth Day'},
  {month: 'April', holidays: 'April 15th - Good Friday, April 17-18th - Easter Sunday/Monday'},
  {month: 'May', holidays: 'National Tourism Month, May 8th - Monthers Day, May 23rd - Victoria Day'},
  {month: 'June', holidays: 'June 19th - Fathers Day, June 21st - National Indigenous Day'},
  {month: 'July', holidays: 'July 1st - Canada Day'},
  {month: 'August', holidays: 'August 1st - Civic Holiday'},
  {month: 'September', holidays: 'September 5th - Labour Day'},
  {month: 'October', holidays: 'Womens History Month, October 10th - Thanksgiving Day, October 31st - Halloween'},
  {month: 'November', holidays: 'November 1st - All Saints Day, November 11th - Rememberance Day'},
  {month: 'December', holidays: 'December 24th - Christmas Eve, December 25th - Christmas Day, December 26th - Boxing Day, December 31st - New Years Eve'}
];

app.use(express.static("public"));
app.use(bodyParser.urlencoded({extended:true}));

app.post('/holidays', (req, res) =>{
  var result = holidays.filter(obj => {
    return obj.month === req.body.month;
  });
  console.log(req.body.month);
  console.log(result);
  res.send(result[0].holidays);
});



const port = 3000;
app.listen(port, () => console.log(`Listening on port ${port}...`));
