const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const cors = require('cors')
const swaggerUI = require('swagger-ui-express');
const swaggerJsDoc = require('swagger-jsdoc');
const PORT = 4000;
const HOST = '0.0.0.0';

app.use(cors())

const options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "Holiday API",
      version: "1.0.0",
      description: "A simple express library for holidays in the year 2022"
    },
    servers: [
      {
        url: "http://localhost:4000"
      }
    ],
  },
  apis: ["*.js"],
};

const specs = swaggerJsDoc(options);
app.use("/api-docs", swaggerUI.serve, swaggerUI.setup(specs));



/**
* @swagger
* tags:
*   name: Holidays
*   description: Holidays 2022 API
*
*/

/**
* @swagger
* components:
*   schemas:
*     Holiday:
*       type: object
*       required:
*         - id
*         - month
*         - holidays
*       properties:
*         id:
*           type: integer
*           description: unique identifier for a month (1-12)
*         month:
*           type: string
*           description: name of the Month
*         holidays:
*           type: string
*           description: comma seperated string of holidays that coorespond to a given month
*       example:
*         id: 12
*         month: December
*         holidays: December 24th - Christmas Eve, December 25th - Christmas Day, December 26th - Boxing Day, December 31st - New Years Eve'
*     Parameters:
*       type: object
*       properties:
*         month:
*           type: string
*/


const holidays = [
  {id: 1, month: 'January', holidays: 'January 1st - New Years Day'},
  {id: 2, month: 'February', holidays: 'Black History Month, February 2nd - Groundhog Day, February 14th - Valentines Day, February 15th - Flag Day'},
  {id: 3, month: 'March', holidays: 'Canada Music Week, March 8th - Internation Womens Day, March 14th - Commonwealth Day'},
  {id: 4, month: 'April', holidays: 'April 15th - Good Friday, April 17-18th - Easter Sunday/Monday'},
  {id: 5, month: 'May', holidays: 'National Tourism Month, May 8th - Monthers Day, May 23rd - Victoria Day'},
  {id: 6, month: 'June', holidays: 'June 19th - Fathers Day, June 21st - National Indigenous Day'},
  {id: 7, month: 'July', holidays: 'July 1st - Canada Day'},
  {id: 8, month: 'August', holidays: 'August 1st - Civic Holiday'},
  {id: 9, month: 'September', holidays: 'September 5th - Labour Day'},
  {id: 10, month: 'October', holidays: 'Womens History Month, October 10th - Thanksgiving Day, October 31st - Halloween'},
  {id: 11, month: 'November', holidays: 'November 1st - All Saints Day, November 11th - Rememberance Day'},
  {id: 12, month: 'December', holidays: 'December 24th - Christmas Eve, December 25th - Christmas Day, December 26th - Boxing Day, December 31st - New Years Eve'}
];

app.use(bodyParser.urlencoded({extended:true}));

/**
 * @swagger
 * /holidays:
 *   post:
 *     summary: Return holidays given month param
 *     tags: [Holidays]
 *     consumes:
 *     - application/x-www-form-urlencoded
 *     requestBody:
 *         content:
 *           application/x-www-form-urlencoded:
 *             schema:
 *               type: object
 *               properties:
 *                 month:
 *                   type: string
 *     responses:
 *       200:
 *         description: Holidays displayed
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Holiday'
 */

app.post('/holidays', (req, res) =>{
  var result = holidays.filter(obj => {
    return obj.month === req.body.month;
  });
  res.send(result[0]);
});

/**
* @swagger
* /holidays/month/{id}:
*   get:
*     summary: Returns list of holidays given month ID as a parameter
*     tags: [Holidays]
*     parameters:
*     - in: path
*       name: id
*       schema:
*         type: integer
*       required: true
*       description: This is the month ID
*     responses:
*       200:
*         description: The holidays object specified
*         content:
*           application/JSON:
*             schema:
*               type: array
*               items:
*                 $ref: '#/components/schemas/Holiday'
*/

app.get('/holidays/month/:id', (req, res) =>{
  var result = holidays.filter(obj => {
    return obj.id === parseInt(req.params.id);
  });
  res.json(result[0]);
})

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);

  // fetch('/holidays/month/12')
  // .then(result => result.json())
  // .then(console.log)
