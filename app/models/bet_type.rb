class BetType
  # BetType::TYPES[:football].first[:code]
  TYPES = {
      football: [
          {
              code: 'over_under',
              name: 'Over/Under',
              other_name: 'Total goals',
              definition: '...',
              example: 'Chelsea - Manchester City. Bet on: Over +2.5',
              selections: [
                  'Over',
                  'Under'
              ],
              line: {
                  min: 0.5,
                  max: 10,
                  step: 0.25
              }
          },
          {
              code: 'over_under_ht',
              name: 'Over/Under HT',
              other_name: 'Over/Under Halftime',
              definition: '...',
              example: 'Chelsea - Manchester City. Bet on: Over -0.75',
              selections: [
                  'Over',
                  'Under'
              ],
              line: {
                  min: 0.5,
                  max: 10,
                  step: 0.25
              }
          },
          {
              code: 'match_odds',
              name: 'Match odds',
              other_name: '1X2;Three ways',
              definition: '...',
              example: 'Chelsea - Manchester City. Bet on: Chelsea',
              selections: 'team',
              drawable: true
          },
          {
              code: 'asian_handicap',
              name: 'Asian Handicap',
              other_name: '',
              definition: '...',
              example: 'Chelsea - Manchester City. Bet on: Chelsea -1.25',
              selections: 'team',
              drawable: false,
              line: {
                  min: -10.0,
                  max: 10.0,
                  step: 0.25
              }
          }
      ],
      horse: [
          {
              code: 'winner',
              name: 'Winner',
              other_name: '1X2;Three ways',
              definition: '...',
              example: 'Lady melodie',
              selections: 'team',
              drawable: false

          },
          {

          },
          {

          },
          {

          },
          {

          },
      ]
  }

end