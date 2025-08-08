import React from 'react';
import { useNavigate } from 'react-router-dom';
import Container from '@mui/material/Container';
import Grid from '@mui/material/Grid';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Typography from '@mui/material/Typography';
import Chip from '@mui/material/Chip';
import Box from '@mui/material/Box';

const bazaarData = [
  {
    name: 'Kalyan',
    openTime: '3:45 PM',
    closeTime: '5:45 PM',
    isOpen: true,
    lastResult: '28-4-59',
  },
  {
    name: 'Milan Day',
    openTime: '3:20 PM',
    closeTime: '5:20 PM',
    isOpen: true,
    lastResult: '15-6-89',
  },
  {
    name: 'Rajdhani Night',
    openTime: '9:30 PM',
    closeTime: '11:30 PM',
    isOpen: false,
    lastResult: '67-4-23',
  },
  {
    name: 'Time Bazar',
    openTime: '1:00 PM',
    closeTime: '3:00 PM',
    isOpen: false,
    lastResult: '45-9-12',
  },
  {
    name: 'Milan Night',
    openTime: '9:20 PM',
    closeTime: '11:20 PM',
    isOpen: false,
    lastResult: '34-7-56',
  },
  {
    name: 'Rajdhani Day',
    openTime: '4:20 PM',
    closeTime: '6:20 PM',
    isOpen: true,
    lastResult: '89-8-34',
  },
  {
    name: 'Supreme Day',
    openTime: '3:25 PM',
    closeTime: '5:25 PM',
    isOpen: true,
    lastResult: '12-3-78',
  },
  {
    name: 'Supreme Night',
    openTime: '9:25 PM',
    closeTime: '11:25 PM',
    isOpen: false,
    lastResult: '56-2-90',
  },
];

function HomePage() {
  const navigate = useNavigate();

  const handleBazaarClick = (bazaarName) => {
    navigate(`/bazaar/${bazaarName.toLowerCase().replace(' ', '-')}`);
  };

  return (
    <Container maxWidth="lg" sx={{ py: 3 }}>
      <Typography
        variant="h5"
        component="h1"
        sx={{
          mb: 3,
          fontWeight: 600,
          color: '#333',
          textAlign: 'center',
        }}
      >
        Satta Matka Bazaars
      </Typography>

      <Grid container spacing={2}>
        {bazaarData.map((bazaar) => (
          <Grid item xs={12} sm={6} md={4} lg={3} key={bazaar.name}>
            <Card
              className="card fade-in"
              sx={{
                cursor: 'pointer',
                height: '100%',
                '&:hover': {
                  transform: 'translateY(-4px)',
                  boxShadow: '0 6px 20px rgba(135, 206, 235, 0.3)',
                },
              }}
              onClick={() => handleBazaarClick(bazaar.name)}
            >
              <CardContent sx={{ p: 2.5 }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 1.5 }}>
                  <Typography
                    variant="h6"
                    component="h2"
                    sx={{
                      fontWeight: 600,
                      fontSize: '1.1rem',
                      color: '#333',
                    }}
                  >
                    {bazaar.name}
                  </Typography>
                  <Chip
                    label={bazaar.isOpen ? 'OPEN' : 'CLOSED'}
                    size="small"
                    sx={{
                      backgroundColor: bazaar.isOpen ? '#4CAF50' : '#f44336',
                      color: 'white',
                      fontWeight: 600,
                      fontSize: '0.7rem',
                    }}
                  />
                </Box>

                <Typography
                  variant="body2"
                  sx={{
                    color: '#666',
                    mb: 1,
                    fontSize: '0.85rem',
                  }}
                >
                  {bazaar.openTime} - {bazaar.closeTime}
                </Typography>

                <Box
                  sx={{
                    backgroundColor: '#f8f9fa',
                    borderRadius: 1,
                    p: 1.5,
                    border: '1px solid #e9ecef',
                  }}
                >
                  <Typography
                    variant="caption"
                    sx={{
                      color: '#666',
                      fontSize: '0.7rem',
                      display: 'block',
                      mb: 0.5,
                    }}
                  >
                    Latest Result:
                  </Typography>
                  <Typography
                    variant="body2"
                    sx={{
                      fontWeight: 700,
                      fontSize: '0.9rem',
                      color: '#87CEEB',
                      letterSpacing: '0.5px',
                    }}
                  >
                    {bazaar.lastResult}
                  </Typography>
                </Box>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>

      <Box sx={{ mt: 4, textAlign: 'center' }}>
        <Typography
          variant="body2"
          sx={{
            color: '#666',
            fontSize: '0.8rem',
            fontStyle: 'italic',
          }}
        >
          Tap on any bazaar to view available games
        </Typography>
      </Box>
    </Container>
  );
}

export default HomePage;
