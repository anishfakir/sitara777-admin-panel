import React from 'react';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';

function ChartPage() {
  return (
    <Container maxWidth="lg" sx={{ py: 5 }}>
      <Box sx={{ textAlign: 'center' }}>
        <Typography variant="h4" component="h1" sx={{ fontWeight: 600, color: '#333' }}>
          Chart
        </Typography>
        <Typography variant="body1" sx={{ mt: 3, color: '#666', fontSize: '1rem' }}>
          All bazaar results and charts will be displayed here only.
        </Typography>
        <Typography variant="body2" sx={{ mt: 2, color: '#87CEEB', fontSize: '0.9rem' }}>
          This is the only place where results are shown - not in individual game screens.
        </Typography>
      </Box>
    </Container>
  );
}

export default ChartPage;
