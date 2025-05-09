import express, { Router } from 'express';
import { errorHandler } from './commons/utils';
import routes from './routes/routes';


const app = express();
const PORT = 3000;

app.use(routes());
app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`📦 Java analyzer listening on http://localhost:${PORT}`);
});
