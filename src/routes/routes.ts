import { Router } from 'express';
import AnalyzerController from '../controllers/analyzer';
import multer from 'multer';

const upload = multer({
  dest: 'uploads/',
  fileFilter: (req, file, cb) => {
    if (file.fieldname === 'zip') {
      if (!file.originalname.endsWith('.zip')) {
        return cb(new Error('Uploaded project must be a .zip file'));
      }
    }
    if (file.fieldname === 'xlsx') {
      if (!file.originalname.endsWith('.xlsx')) {
        return cb(new Error('Uploaded specification must be a .xlsx file'));
      }
    }
    cb(null, true);
  }
});

export default function routes() {
  const router = Router();
  const analyzerController = new AnalyzerController();

  router.post(
    '/analyze',
    upload.fields([{ name: 'zip' }, { name: 'xlsx' }]),
    analyzerController.post.bind(analyzerController) // bind is important
  );
  
  
  return router;
}


