library(rtweet)
library(readr)

ser_mentions <- get_mentions(token = ser_token())
mentioners <- lookup_tweets(ser_mentions$status_id, token = ser_token())
ser_tweets <- get_timeline("societyforepi", n = 1e4, token = ser_token())
followers <- get_followers("societyforepi", n = 1e5, token = ser_token())
n_followers_new <- data.frame(
  date = lubridate::today(),
  n_followers = nrow(followers)
)

n_followers <- rbind(
  n_followers,
  n_followers_new
)

write_rds(ser_mentions, "ser_mentions.Rds")
write_rds(ser_mentions, "mentioners")
write_rds(ser_mentions, "ser_tweets")
