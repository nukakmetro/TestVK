/// Модель отзыва.
struct Review: Decodable {

    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    /// СИзображение пользоваля
    let avatar_url: String?
    /// Оставленый рейтинг пользователем
    let rating: Int
    /// Имя пользователя
    let first_name: String
    /// Фамилия пользователя
    let last_name: String
}
