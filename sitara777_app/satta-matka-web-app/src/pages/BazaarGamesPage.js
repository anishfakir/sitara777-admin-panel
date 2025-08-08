import React from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import Container from '@mui/material/Container';
import Grid from '@mui/material/Grid';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import IconButton from '@mui/material/IconButton';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';

const gameTypes = [
  {
    name: 'Single Digit',
    description: 'Play with single digit (0-9)',
    rate: '1:9.5',
  },
  {
    name: 'Jodi',
    description: 'Play with two digit combination (00-99)',
    rate: '1:95',
  },
  {
    name: 'Single Patti',
    description: 'Play with three digit combination',
    rate: '1:142',
  },
  {
    name: 'Double Patti',
    description: 'Play with double digit pattern',
    rate: '1:285',
  },
  {
    name: 'Triple Patti',
    description: 'Play with triple digit pattern',
    rate: '1:950',
  },
  {
    name: 'Half Sangam',
    description: 'Combination of open/close with patti',
    rate: '1:1425',
  },
  {
    name: 'Full Sangam',
    description: 'Complete combination play',
    rate: '1:9500',
  },
];

function BazaarGamesPage() {
  const { bazaarName } = useParams();
  const navigate = useNavigate();

  // Format bazaar name for display
  const displayBazaarName = bazaarName
    .split('-')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');

  const handleGameClick = (gameType) => {
    navigate(`/game/${bazaarName}/${gameType.name.toLowerCase().replace(' ', '-')}`);
  };

  const handleBackClick = () => {
    navigate('/');
  };

  return (
    <Container maxWidth="lg" sx={{ py: 3 }}>
      <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
        <IconButton onClick={handleBackClick} sx={{ mr: 1, color: '#87CEEB' }}>
          <ArrowBackIcon />
        </IconButton>
        <Typography
          variant="h5"
          component="h1"
          sx={{
            fontWeight: 600,
            color: '#333',
          }}
        >
          {displayBazaarName} Games
        </Typography>
      </Box>

      <Typography
        variant="body1"
        sx={{
          mb: 3,
          color: '#666',
          textAlign: 'center',
        }}
      >
        Select a game type to place your bet
      </Typography>

      <Grid container spacing={2}>
        {gameTypes.map((game) => (
          <Grid item xs={12} sm={6} md={4} key={game.name}>
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
              onClick={() => handleGameClick(game)}
            >
              <CardContent sx={{ p: 3 }}>
                <Typography
                  variant="h6"
                  component="h2"
                  sx={{
                    fontWeight: 600,
                    fontSize: '1.1rem',
                    color: '#333',
                    mb: 1,
                  }}
                >
                  {game.name}
                </Typography>

                <Typography
                  variant="body2"
                  sx={{
                    color: '#666',
                    fontSize: '0.85rem',
                    mb: 2,
                    lineHeight: 1.4,
                  }}
                >
                  {game.description}
                </Typography>

                <Box
                  sx={{
                    backgroundColor: '#e8f5e8',
                    borderRadius: 1,
                    p: 1.5,
                    border: '1px solid #c8e6c9',
                    textAlign: 'center',
                  }}
                >
                  <Typography
                    variant="caption"
                    sx={{
                      color: '#2e7d32',
                      fontSize: '0.7rem',
                      display: 'block',
                      mb: 0.5,
                    }}
                  >
                    Win Rate:
                  </Typography>
                  <Typography
                    variant="body2"
                    sx={{
                      fontWeight: 700,
                      fontSize: '1rem',
                      color: '#2e7d32',
                    }}
                  >
                    {game.rate}
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
          Tap on any game to start playing
        </Typography>
      </Box>
    </Container>
  );
}

export default BazaarGamesPage;
