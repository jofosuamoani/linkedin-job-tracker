## Live Demo

https://linkedin-job-tracker-alpha.vercel.app/

The project is deployed on Vercel so it can be interacted with directly.

# Setup

This project was built and tested with Node.js and npm. The runnable frontend app is located in the `frontend/` directory.

## Run locally

```bash
cd frontend
npm install
npm run dev

## What I built and why I built it

I went with Problem 3 and decided to build a simplified version of LinkedIn's job tracker feature with improved filtering and sorting. I added a select to allow for sorting, and I separated the current filter select into two selects, one for selecting either "Date applied" or "Date posted" and one for selectin the time constraint.

As I'm currently in the job market, it is a feature which I use almost everyday, and I think it's a big UX gap that there is no way to filter and/or sort by the dates which I applied. Personally, I find this information to be more useful to me than the dates the jobs were posted.

# Key decisions & tradeoffs

- In order to focus on the frontend implementation, I used local mock data instead of building a backend API and database. A backend API would be more realistic but I decided to sacrifice that for faster iteration and simpler implementation.
- I stored the states for the jobs and the filtering/sorting in the main App component to allow for sharing across the child pages that needed them.
- For filtering specifically, I used two selects, one for "Date applied" and one for "Date posted". This creates clear functionality for the user and allows for easier addition of additional filtering options in the future.
- In order for users to maintain their filtering and sorting selections, I stored that data in local storage. It would be better to use an API in reality, but I implemented it this way to maintain the frontend scope of the project.
- Instead of using a styling library/framework, I used plain CSS for simplicity and faster iteration. If the design were to become more complex, plain CSS might prove to be more work but for our current implementation it is sufficient.
- The job card displays "Date applied" or "Date posted" based on the selected filter. This reduces noise and reflects the current context.
- I added empty and loading states to reflect what the implementation would look like with an actual API and database. It allows for easier integration of a backend later on.
- Since the jobs data is owned and stored in our App component, I stored the empty and loading states there as they are dependent on that data.
- Instead of having a "Clear" button like the current LinkedIn job tracker has for the filter, I added an "All time" option. This creates a more straightforward and clean UX, and is more intuitive for the user. In the future, if we were to add more filtering options, this might make clearing all the filters more difficult and we might actually need to implement a way to clear all filters if the user wanted to.
- Defaulted to “Date applied”, “Past 24 hours”, and “Newest first” as I believe users would want to see the most recent activity immediately. This, of course, is an assumption so certain users could prefer to see older information first.
- I hid the pagination controls when not needed as this reduces noise, and prevents users from trying to use it when they can't.
- Kept the page state and all list and pagination logic in the JobsList component. This keeps all the list logic in the same place and allows the Pagination component to be mainly presentational.
- Added labels to improve accessibility, as this is important for frontend features.

# What I intentionally left out

- In order to focus on the frontend implementation, I used local mock data instead of building a backend API and database. A backend API would be more realistic but I decided to sacrifice that for faster iteration and simpler implementation.
- The "connections", "notes", and response status features were ommitted to maintain the scope of the project, which is the filtering and sorting implementation.
- I did not add a detailed job posting for each job, as it does not fit the filtering and sorting scope of the project.
- The implementation is scoped only to the "Applied" page to focus on the single workflow which I wanted to improve. So there was no need to implement the other pages.
- Changing the job stage was left out to maintaing the focus on the sorting and filtering implementation only.

# What breaks first under pressure

- With large datasets, the filtering and sorting may become slow so I may need to find a way to optimize. An improvement could be moving these operations to a backend.
- Since we are storing the user selections in local storage, they don't sync across sessions or different devies, and can easily be cleared by the user. If we had a backend implementation it would be better to store this information in the server so that we could persist this information across sessions and devices.
- The current filtering and sorting options are limited. If we wanted to allow more options to users, we would need to add these later on.

# What I'd build next

- I would implement a backend API and a database to be able to store and fetch real data. This would be a more realistic implementation and would allow for scalabilty, and server-side manipulation of the data. It would also allow us to store our user selections for our filtering and sorting in the server.
- I would add more filtering options such as "Past month" and "Past year", and add more sorting options such as sorting company names or job titles alphabetically.
```
